-module(chatv4).
-export([start_server/1]).

start_server(Port) ->
  {ok, LSock} = gen_tcp:listen(Port, [binary, {active, once}, {packet, line}, {reuseaddr, true}]),
  RoomManager = spawn(fun()-> roomManager(#{}) end),
  DefaultRoom = spawn(fun()-> room([]) end),
  spawn(fun() -> acceptor(LSock, RoomManager,DefaultRoom) end),
  ok.

acceptor(LSock, RoomManager, DefaultRoom) ->
  {ok, Sock} = gen_tcp:accept(LSock),
  spawn(fun() -> acceptor(LSock, RoomManager,DefaultRoom) end),
  DefaultRoom ! {enter, self()},
  user(Sock, RoomManager, DefaultRoom).

roomManager(Rooms)->
  receive
    {enter,Room, User} ->
      io:format("user entered~n", []),
      case maps:find(Room) of
        {ok,N} ->
          Room ! {enter, User},
          roomManager(maps:put(Room,N+1,Rooms));
        error ->
          NewRoom = spawn(fun()-> room([]) end),
          NewRoom ! {enter, User},
          roomManager(maps:put(NewRoom,1,Rooms))
        end;
    {leave, Room, User} ->
      Room ! {leave, User},
      case maps:find(Room) of
        {ok,1} ->
          roomManager(maps:remove(Room,Rooms));
        {ok,N} ->
          roomManager(maps:update(Room,N-1,Rooms))
        end
  end.

room(Pids) ->
  receive
    {enter, Pid} ->
      io:format("user entered~n", []),
      room([Pid | Pids]);
    {line, Data} = Msg ->
      io:format("received ~p~n", [Data]),
      [Pid ! Msg || Pid <- Pids],
      room(Pids);
    {leave, Pid} ->
      io:format("user left~n", []),
      room(Pids -- [Pid])
  end.

% O user só permite que o socket envie outra mensagem quando recebe a ultima do room,
% isto é, a mensagem já foi atendida (broadcasted) pelo room. 

%mensagem room = << <<"\room ">>, resto >>
user(Sock, Rooms, Room) ->
  % [Default,Miei,Bar,Support] = Rooms,
  Self = self(),
  receive
    {line, {Self, Data}} ->
      inet:setopts(Sock, [{active, once}]),
      gen_tcp:send(Sock, Data),
      user(Sock,Rooms,Room);
    {line, {_, Data}} ->
      gen_tcp:send(Sock, Data),
      user(Sock,Rooms,Room);
    {tcp, _, <<"\\room ",NewRoom/binary>>} ->
      Room ! {leave, self()},
      Room ! {enter, self()},
      inet:setopts(Sock, [{active, once}]),
      RoomName=lists:droplast(lists:droplast(binary_to_list(NewRoom))),
      gen_tcp:send(Sock, <<"Sucess moved to ",RoomName/binary>>),
      user(Sock,Rooms,Room);
    {tcp, _, Data} ->
      Room ! {line, {Self, Data}},
      user(Sock,Rooms,Room);
    {tcp_closed, _} ->
      Room ! {leave, self()};
    {tcp_error, _, _} ->
      Room ! {leave, self()}
  end.

