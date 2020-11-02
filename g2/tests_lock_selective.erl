-module(tests_lock_selective).
-export([run/0]).
   

run() ->
    Lock=lock_selective:create(),
    spawn(fun()->runner1(Lock) end),
    spawn(fun()->runner2(Lock) end),
    spawn(fun()->runner3(Lock) end),
    spawn(fun()->runner4(Lock) end),
    spawn(fun()->destroyer(Lock) end)
.

runner1(Lock) ->
    timer:sleep(500),
    io:put_chars("Queue Writer 1\n"),
    success_acquired=lock_selective:acquire(Lock,write),
    io:put_chars("Writing 1\n"),
    timer:sleep(1000),
    io:put_chars("Wrote 1\n"),
    success_released=lock_selective:release(Lock).

runner2(Lock)->
    timer:sleep(600),
    io:put_chars("Queue Writer 2\n"),
    success_acquired=lock_selective:acquire(Lock,write),
    io:put_chars("Writing 2\n"),
    timer:sleep(1000),
    io:put_chars("Wrote 2\n"),
    success_released=lock_selective:release(Lock).


runner3(Lock) ->
    timer:sleep(100),
    io:put_chars("Queue Reader 1\n"),
    success_acquired=lock_selective:acquire(Lock,read),
    io:put_chars("Reading 1\n"),
    timer:sleep(1000),
    io:put_chars("Read 1\n"),
    success_released=lock_selective:release(Lock),

    timer:sleep(100),
    io:put_chars("Queue Reader 2\n"),
    success_acquired=lock_selective:acquire(Lock,read),
    io:put_chars("Reading 2\n"),
    timer:sleep(1000),
    io:put_chars("Read 2\n"),
    success_released=lock_selective:release(Lock).

runner4(Lock)->
    timer:sleep(1200),
    io:put_chars("Queue Reader 3\n"),
    success_acquired=lock_selective:acquire(Lock,read),
    io:put_chars("Reading 3\n"),
    timer:sleep(1000),
    io:put_chars("Read 3\n"),
    success_released=lock_selective:release(Lock).

destroyer(Lock)->
    timer:sleep(5000),
    success_destroyed=lock_selective:destroy(Lock).


