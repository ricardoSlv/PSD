-module(myprioqueue).
-export([create/0,enqueue/3,dequeue/1]).

create()->[].

enqueue([],Item,Prio)->[{Item,Prio}];
enqueue([{I,P}|PrioQueueTail],Item,Prio) when Prio > P ->[{Item,Prio},{I,P}|PrioQueueTail];
enqueue([{I,P}|PrioQueueTail],Item,Prio) ->[{I,P}|enqueue(PrioQueueTail,Item,Prio)].

dequeue([])->empty;
dequeue([{I,_}|PrioQueueTail])->{I,PrioQueueTail}.

