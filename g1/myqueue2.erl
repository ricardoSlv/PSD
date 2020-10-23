% Mais eficiente
-module(myqueue2).
-export([create/0,enqueue/2,dequeue/1,reverse/1]).

create()->{[],[]}.

enqueue({In,Out},Elem)->{[Elem|In],Out}.

dequeue({[],[]})->empty;
dequeue({In,[]})->dequeue({[],reverse(In)});
dequeue({In,[H|TailOut]})->{H,{In,TailOut}}.

reverse([])->[];
reverse([H|T])->reverse(T)++[H].

