%chatv4 Room Manager allowing users to be in multiple rooms working
-module(chatv4).
-export([start_server/1]).

start_server(Port) ->
  {ok, LSock} = gen_tcp:listen(Port, [binary, {active, once}, {packet, line}, {reuseaddr, true}]),
  DefaultRoom = spawn(fun()-> room([]) end),
  RoomManager = spawn(fun()-> roomManager(#{"default"=>{0,DefaultRoom}}) end),
  register(roomManager,RoomManager),
  spawn(fun() -> acceptor(LSock, RoomManager,DefaultRoom) end),
  ok.

acceptor(LSock, RoomManager, DefaultRoom) ->
  {ok, Sock} = gen_tcp:accept(LSock),
  io:format("User connected~n"),
  spawn(fun() -> acceptor(LSock, RoomManager,DefaultRoom) end),
  
  roomManager ! {enter, "default", self()},
  receive
    {entered,DefaultRoom}->ok
  end,
  user(Sock, {"default",DefaultRoom}).

% Rooms = map(RoomName=>{UsersInside,RoomPid})
roomManager(Rooms)->
  receive
    {enter, RoomName, User} ->
      io:format("User ~p requested to enter ~p~n",[User,RoomName]),
      case maps:find(RoomName,Rooms) of
        {ok,{N,RoomPid}} ->
          io:put_chars("Found room requested\n"),
          RoomPid ! {enter, User},
          roomManager(maps:put(RoomName,{N+1,RoomPid},Rooms));
        _ ->
          io:put_chars("Couldnt find room requested\n"),
          io:format("Spawning room ~p~n",[RoomName]),
          NewRoomPid = spawn(fun()-> room([]) end),
          NewRoomPid ! {enter, User},
          roomManager(maps:put(RoomName,{1,NewRoomPid},Rooms))
        end;
    {leave, RoomName, User} ->
      case maps:find(RoomName,Rooms) of
        {ok,{1,RoomPid}} ->
          RoomPid ! {leave, User},
          case RoomName of 
            "default"->
              roomManager(Rooms);
            _->
              RoomPid ! {close},
              roomManager(maps:remove(RoomName,Rooms))
          end;
        {ok,{N,RoomPid}} ->
          RoomPid ! {leave, User},
          roomManager(maps:update(RoomName,{N-1,RoomPid},Rooms));
        BadAnswer->io:format("Something bad happened on leave ~p~n",[BadAnswer])
      end
  end.

room(Pids) ->
  receive
    {enter, UserPid} ->
      io:format("Room ~p user entered~n", [self()]),
      UserPid ! {entered,self()},
      room([UserPid | Pids]);
    {line, Data} = Msg ->
      io:format("Room ~p received ~p~n  Users ~p~n",[self(),Data,Pids]),
      [UserPid ! Msg || UserPid <- Pids],
      room(Pids);
    {leave, UserPid} ->
      io:format("Room ~p user left~n",[self()]),
      room(Pids -- [UserPid]);
    {close}->
      io:format("Room ~p closed~n",[self()])
  end.

% O user só permite que o socket envie outra mensagem quando recebe a ultima do room,
% isto é, a mensagem já foi atendida (broadcasted) pelo room. 

%mensagem room = << <<"\room ">>, resto >>
user(Sock, {RoomName,RoomPid}) ->
  Self = self(),
  receive
    {line, {Self, Data}} ->
      inet:setopts(Sock, [{active, once}]),
      gen_tcp:send(Sock, Data),
      user(Sock,{RoomName,RoomPid});
    {line, {_, Data}} ->
      gen_tcp:send(Sock, Data),
      user(Sock,{RoomName,RoomPid});
    {tcp, _, <<"\\room ",NewRoom/binary>>} ->
      roomManager ! {leave, RoomName, self()},
      NewRoomName=lists:droplast(binary_to_list(NewRoom)),
      roomManager ! {enter, NewRoomName, self()},
      receive
        {entered,NewRoomPid}->
          inet:setopts(Sock, [{active, once}]),
          gen_tcp:send(Sock, <<"Sucess moved to ",NewRoom/binary>>),
          io:format("User ~p moved to Room ~p~n",[self(),NewRoomPid]),
          user(Sock,{NewRoomName,NewRoomPid})
      end;
    {tcp, _, Data} ->
      RoomPid ! {line, {Self, Data}},
      user(Sock,{RoomName,RoomPid});
    {tcp_closed, _} ->
      roomManager ! {leave, RoomName, self()};
    {tcp_error, _, _} ->
      roomManager ! {leave, RoomName, self()}
  end.

