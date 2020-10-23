-module(fib).
-export([fib/1]).

fib(N)->fib(N,1,1).
fib(N,_,Y) when N<2 -> Y;
fib(N,X,Y) -> fib(N-1,Y,X+Y).







