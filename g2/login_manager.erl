-module(login_manager).
-export([start/0,create_account/2,close_account/2,login/2,logout/1,online/0]).

start()->
    Pid = spawn(fun()->loop(#{}) end),
    register(?MODULE,Pid).

loop(Accounts)->
    receive 
        {{create_account,Username, Passwd},From} ->
            case maps:find(Username,Accounts) of 
                {ok,_} -> 
                    From ! {already_exists,?MODULE},
                    loop(Accounts);
                _ -> 
                    From ! {ok,?MODULE},
                    loop(maps:put(Username,{Passwd,false},Accounts))
            end;
        {{close_account, Username, Passwd},From} ->
            case maps:find(Username,Accounts) of 
                {ok,{Passwd,_}} -> 
                    From ! {ok,?MODULE},
                    loop(maps:remove(Username,Accounts));
                {ok,_} -> 
                    From ! {invalid_passwd,?MODULE},
                    loop(maps:remove(Username,Accounts));
                error -> 
                    From ! {invalid_username,?MODULE},
                    loop(Accounts)
            end;
        {{login, Username, Passwd},From} ->
            case maps:find(Username,Accounts) of 
                {ok,{Passwd,false}} -> 
                    From ! {ok,?MODULE},
                    loop(maps:update(Username,{Passwd,true},Accounts));
                {ok,{Passwd,true}} -> 
                    From ! {already_logged_in,?MODULE},
                    loop(Accounts);
                {ok,_} -> 
                    From ! {invalid_passwd,?MODULE},
                    loop(Accounts);
                error -> 
                    From ! {invalid_username,?MODULE},
                    loop(Accounts)
            end;
        {{logout,Username},From} ->
            From ! {ok,?MODULE}, 
            case maps:find(Username,Accounts) of 
                {ok,{Passwd,_}} -> 
                    From ! {ok,?MODULE},
                    loop(maps:update(Username,{Passwd,false}));
                error ->
                    loop(Accounts)
            end;
        {{online},From} ->
            From ! {ok,?MODULE}, 
            loop(Accounts);
        _ -> error_logger:error_report("Forbidden message on login_manager"),
        loop(Accounts)
    end.



rpc(Req)->
    ?MODULE ! {Req,self()},
    receive
        {Result, ?MODULE}->Result
    end.

create_account(Username, Passwd) -> 
    rpc({create_account,Username,Passwd}).

close_account(Username, Passwd) -> 
    rpc({close_account,Username,Passwd}).

login(Username, Passwd) -> 
    rpc({login,Username,Passwd}).

logout(Username) -> 
    rpc({logout,Username}).

online() -> 
    rpc({online}).
