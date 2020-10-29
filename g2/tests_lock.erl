-module(tests_lock).
-export([run/0]).

run() ->
    Lock=lock:create(),
    error_logger:error_report(Lock),
    success_acquired=lock:acquire(Lock,read),
    success_acquired=lock:acquire(Lock,read),
    success_released=lock:release(Lock),
    success_released=lock:release(Lock),
    success_acquired=lock:acquire(Lock,write),
    % success_acquired=lock:acquire(Lock,write),
    success_released=lock:release(Lock),
    success_destroyed=lock:destroy(Lock).