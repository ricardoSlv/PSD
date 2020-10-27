-module(count).
-export([start/0,stop/1,getVal/1,increment/1]).

start()->
    spawn(fun()->counter(0) end).

stop(Counter)->
    Counter ! stop.

counter(Val)->
    receive 
        increment ->
            counter(Val+1);
        {value,From} ->
            From ! {self(),Val},
            counter(Val);
        stop -> true;
        _ -> error_logger:error_report("Forbidden message on counter"),
        counter(Val)
    end.

getVal(Counter)->
    Counter ! {value,self()},
    receive
        {Counter,Val} -> Val
    end.

increment(Counter) ->
    Counter ! increment.
