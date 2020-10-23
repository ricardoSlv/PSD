-module(testes).
-export([run/0]).

run()->
    Q1=myqueue2:create(),
    Q2=myqueue2:enqueue(Q1,1),
    Q3=myqueue2:enqueue(Q2,2),
    Q4=myqueue2:enqueue(Q3,3),
    Q5=myqueue2:enqueue(Q4,4),
    Q6=myqueue2:enqueue(Q5,5),
    {1,Q7}=myqueue2:dequeue(Q6),
    {2,Q8}=myqueue2:dequeue(Q7),
    {3,Q9}=myqueue2:dequeue(Q8),
    Q10=myqueue2:enqueue(Q9,6),
    {4,Q11}=myqueue2:dequeue(Q10),
    {5,Q12}=myqueue2:dequeue(Q11),
    Q12,

    PQ1=myprioqueue:create(),
    PQ2=myprioqueue:enqueue(PQ1,1,10),
    PQ3=myprioqueue:enqueue(PQ2,2,8),
    PQ4=myprioqueue:enqueue(PQ3,3,9),
    PQ5=myprioqueue:enqueue(PQ4,4,1),
    PQ6=myprioqueue:enqueue(PQ5,5,30),
    {5,PQ7}=myprioqueue:dequeue(PQ6),
    {1,PQ8}=myprioqueue:dequeue(PQ7),
    {3,PQ9}=myprioqueue:dequeue(PQ8),
    PQ10=myprioqueue:enqueue(PQ9,6,0),
    {2,PQ11}=myprioqueue:dequeue(PQ10),
    {4,PQ12}=myprioqueue:dequeue(PQ11),
    PQ12.

