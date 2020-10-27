-module(login_manager).
-export([start/0,stop/0,create_account/2,close_account/2,login/2,logout/2,online/0]).

start()->
    Pid = spawn(fun()->loop(#{}) end),
    register(?MODULE,Pid).

stop()->
    ?MODULE ! stop,
    unregister(?MODULE).

loop(Accounts)->
    receive 
        {{create_account,Username, Passwd},From} ->
            case maps:find(Username,Accounts) of 
                {ok,_} -> 
                    From ! {already_exists,?MODULE},
                    loop(Accounts);
                _ -> 
                    From ! {success_create,?MODULE},
                    loop(maps:put(Username,{Passwd,false},Accounts))
            end;
        {{close_account, Username, Passwd},From} ->
            case maps:find(Username,Accounts) of 
                {ok,{Passwd,_}} -> 
                    From ! {success_delete,?MODULE},
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
                    From ! {success_login,?MODULE},
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
        {{logout,Username,Passwd},From} ->
            case maps:find(Username,Accounts) of 
                {ok,{Passwd,true}} -> 
                    From ! {success_logout,?MODULE},
                    loop(maps:update(Username,{Passwd,false},Accounts));
                {ok,{Passwd,false}} -> 
                    From ! {not_logged_in,?MODULE},
                    loop(maps:update(Username,{Passwd,false},Accounts));
                {ok,_} -> 
                    From ! {invalid_password,?MODULE},
                    loop(maps:update(Username,{Passwd,false},Accounts));
                error ->
                    From ! {invalid_username,?MODULE},
                    loop(Accounts)
            end;
        {{online},From} ->
            LoggedInAccNames = maps:keys(
                maps:filter(
                    fun(_,{_,LoggedIn}) -> LoggedIn end,
                    Accounts
                )
            ),
            From ! {LoggedInAccNames,?MODULE}, 
            loop(Accounts);
        stop -> true;
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

logout(Username,Passwd) -> 
    rpc({logout,Username,Passwd}).

online() -> 
    rpc({online}).
