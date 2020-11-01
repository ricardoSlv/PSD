-module(lock).
-export([create/0,destroy/1,acquire/2,release/1]).

create()->
    io:put_chars("Lock Started\n"),
    spawn(fun()->loop(0,none,false) end).

loop(Readers,PendingWriter,Writing) -> 
    receive 
        {write,From} when (PendingWriter == none) and ((Readers > 0) or (Writing==true)) ->
            loop(Readers,From,Writing);
        {write,From} when (Readers == 0) and (Writing==false) ->
            %É garantido que nao há PendingWriter nesta situação
            From ! {success_acquired,self()},
            loop(0,none,true);
        {read,From} when (PendingWriter == none) and (Writing == false) ->
            From ! {success_acquired,self()},
            loop(Readers+1,none,false);
        {release,From} when (Readers > 1) ->
            From ! {success_released,self()},
            loop(Readers-1,PendingWriter,false);
        {release,From} when (Readers == 1) ->
            From ! {success_released,self()},
            case PendingWriter of 
                none ->
                    loop(0,none,false);
                _ ->
                    PendingWriter ! {success_acquired,self()}
                end
            ;
        {release,From} when (Readers == 0) ->
            From ! {success_released,self()},
            case PendingWriter of 
                none ->
                    loop(0,none,false);
                _ ->
                    PendingWriter ! {success_acquired,self()},
                    loop(0,none,true)
            end;
        {stop,From} -> From ! {success_destroyed,self()};
        _ -> 
        error_logger:error_report("Forbidden message on lock empty"),
        loop(Readers,PendingWriter,Writing)
    end
.

rpcId(Req,LockPid)->
    LockPid ! {Req,self()},
    receive
        {Result, LockPid}->Result
    end
.

acquire(Lock, Action) ->
    case Action of
        read -> rpcId(read,Lock);
        write -> rpcId(write,Lock);
        _ -> error_logger:error_report("Undefined action on lock acquire")
    end
.

release(Lock) -> 
    rpcId(release,Lock).

destroy(Lock) ->
    rpcId(stop,Lock).
