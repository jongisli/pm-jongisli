-module(pmuse).
-export([pmmap/2, treeforall/2, tree_of/1]).
-import(pm).

%influenced by: http://bc.tech.coop/blog/070601.html
pmmap(F, L) ->
    Parent = self(),
    PidsVals = [{pm:newVanilla(), X} || X <- L],
    [receive {Pid, IVar, _} -> pm:get(IVar) end || 
	Pid <- [spawn(fun() -> Parent ! {self(), V, pm:put(V,F(X))} end) || 
		   {V,X} <- PidsVals]].

treeforall({node, X, Left, Right}, P) ->
    PredRes = P(X),
    io:format("Checking ~p~n",[X]),
    if 
	PredRes == false ->
	    false;
	true -> 
	    treeforall(Left, P),
	    treeforall(Right, P)
    end;
treeforall(leaf,_) ->
    io:format("Reached end~n",[]),
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
