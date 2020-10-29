-module(lock).
-export([create/0,destroy/1,acquire/2,release/1]).

create()->
    spawn(fun()->emptyLoop() end).


emptyLoop()->
    receive 
        {read,From} ->
            From ! {success_acquired,self()},
            readingLoop(1);
        {write,From} ->
            From ! {success_acquired,self()},
            writingLoop([]);
        {stop,From} -> From ! {success_destroyed,self()};
        _ -> 
        error_logger:error_report("Forbidden message on lock empty"),
        emptyLoop()
    end.

readingLoop(Readers)->
    receive 
        {read,From} ->
            From ! {success_acquired,self()},
            readingLoop(Readers+1);
        {write,From} ->
            writerWaitingLoop([{From,write}],Readers);
        {release,From} ->
            From ! {success_released,self()},
            case Readers - 1 of
                0 -> emptyLoop();
                _ -> readingLoop(Readers-1)
            end;
        {stop,From} -> From ! {success_destroyed,self()};
        _ -> 
            error_logger:error_report("Forbidden message on lock reading"),
            readingLoop(Readers)
    end.


writerWaitingLoop(Queue,Readers)->
    receive 
        {read,From} ->
            writerWaitingLoop(Queue++{From,read},Readers);
        {write,From} ->
            writerWaitingLoop(Queue++{From,write},Readers);
        {release,From} ->
            From ! {success_released,self()},
            case Readers - 1 of
                0 -> writingLoop(Queue);
                _ -> writerWaitingLoop(Queue,Readers-1)
            end;
        {stop,From} -> From ! {success_destroyed,self()};
        _ -> 
            error_logger:error_report("Forbidden message on lock writerWaiting"),
            writerWaitingLoop(Queue,Readers)
    end.

writingLoop(Queue)->
    receive 
        {read,From} ->
            writingLoop(Queue++{From,read});
        {write,From} ->
            writingLoop(Queue++{From,write});
        {release,From} ->
            From ! {success_released,self()},
            Readers = lists:filter(
                fun({_,Action}) -> Action=:=read end,
                Queue
            ),
            Writers = lists:filter(
                fun({_,Action}) -> Action=:=write end,
                Queue
            ),
            lists:foreach(
                fun({Pid,_})->Pid ! {success_acquired,self()} end,
                Readers
            ),
            NumberWriters = length(Writers),
            NumberReaders = length(Readers),
            case NumberWriters of
                0 -> 
                    case NumberReaders of
                        0 -> emptyLoop();
                        _ -> readingLoop(NumberReaders)
                    end;
                _ -> 
                    case NumberReaders of
                        0 -> 
                            [H|T] = Writers, 
                            H ! {success_acquired,self()},
                            writingLoop(T);
                        _ -> writerWaitingLoop(Writers,NumberReaders)
                    end
            end;
        {stop,From} -> From ! {success_destroyed,self()};
        _ -> 
            error_logger:error_report("Forbidden message on lock writing"),
            writingLoop(Queue)
    end.



rpcId(Req,ServerPid)->
    ServerPid ! {Req,self()},
    receive
        {Result, ServerPid}->Result
    end.

acquire(Lock, Action) ->
    case Action of
        read -> rpcId(read,Lock);
        write -> rpcId(write,Lock);
        _ -> error_logger:error_report("Undefined action on lock acquire")
    end.

release(Lock) -> 
    rpcId(release,Lock).

destroy(Lock) ->
    rpcId(stop,Lock).
