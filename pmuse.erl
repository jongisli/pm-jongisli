-module(pmuse).
-export([pmmap/2]).
-import(pm).

%influenced by: http://blog.vmoroz.com/2011/01/erlang-pmap.html
pmmap(F, L) ->
    [pm:get(Pid) || 
	{Pid,_} <- [{Pid,pm:put(Pid,Var)} || 
		       {Pid,Var} <- [{pm:newVanilla(), F(X)} || X <- L]]].
