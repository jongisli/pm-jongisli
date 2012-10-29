-module(pmuse).
-export([pmmap/2]).
-import(pm).

%influenced by: http://bc.tech.coop/blog/070601.html
pmmap(F, L) ->
    [pm:get(Pid) || 
	{Pid,_} <- [{Pid,pm:put(Pid,Var)} || 
		       {Pid,Var} <- [{pm:newVanilla(), F(X)} || X <- L]]].
