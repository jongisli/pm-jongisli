-module(pmuse).
-export([pmmap/2, treeforall/2, tree_of/1]).
-import(pm).

%influenced by: http://bc.tech.coop/blog/070601.html
pmmap(F, L) ->
    Parent = self(),
    PidsVals = [{pm:newVanilla(), X} || X <- L],
    [receive {IVar, _} -> pm:get(IVar) end || 
	Pid <- [spawn(fun() -> Parent ! {V, pm:put(V,F(X))} end) || 
		   {V,X} <- PidsVals]].


% ////
% WARNING: Only works if pm:put/2 responds with a message.
%
% Concurrently checks if each node-value in a tree satisfies a predicate.
% It's concurrent since we try to put the node-value into a Princess IVar
% which gives us false if the predicate is erroneous.  
% ////
treeforall({node, X, Left, Right}, P) ->
    Princess = pm:newPrincess(P),
    Put = pm:put(Princess, X),
    if 
	Put == predicate_false ->
	    false;
	true -> 
	    treeforall(Left, P),
	    treeforall(Right, P)
    end;
treeforall(leaf,_) ->
    true.


tree_of(Xs) -> build([{leaf,X} || X <- Xs ]).

build([]) -> 
    leaf;
build([{leaf,X}]) -> 
    {node, X, leaf, leaf};
build([{{node,Y,T1,T2}, X}]) -> 
    {node, Y, T1, build([{T2, X}])};
build(List) -> 
    build(sweep(List)).

sweep([]) -> 
    [];
sweep([Ts]) -> 
    [Ts];
sweep([{T1,X1},{T2,X2}|Ts]) -> 
    [{{node, X1, T1, T2},X2}|sweep(Ts)].
