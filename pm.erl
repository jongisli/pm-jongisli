-module(pm).
-export([newVanilla/0, newPrincess/1, get/1, put/2, compromised/1]).

get(V) ->
    rpc(V, get).

put(V, T) ->
    V ! {self(), {put, T}}.

rpc(Pid, Request) ->
    Pid ! {self(), Request},
    receive
	{Pid, Response} ->
	    Response
    end.

compromised(V) ->
    rpc(V, compromised).

newVanilla() ->
    spawn(fun() -> ivar_loop({vanilla, empty, false}) end).

newPrincess(P) ->
    spawn(fun() -> ivar_loop({princess, empty, P}) end).

ivar_loop({vanilla, T, Compromised}) ->
    receive
        {From, get} ->
            if 
                T == empty -> 
		    self() ! {From, get},
		    ivar_loop({vanilla, T, Compromised});
                (true) -> 
		    From ! {self(), T},
                    ivar_loop({vanilla, T, Compromised})
	    end;
	{_, {put, NewT}} ->
	    if
		T == empty ->
		    ivar_loop({vanilla, NewT, false});
		(true) ->
		    ivar_loop({vanilla, T, true})
	    end;
	{From, compromised} ->
	    From ! {self(), Compromised},
	    ivar_loop({vanilla, T, Compromised})
    end;

ivar_loop({princess, T, P}) ->
    receive
        {From, get} ->
            if 
                T == empty -> 
		    self() ! {From, get},
		    ivar_loop({princess, T, P});
                (true) -> 
		    From ! {self(), T},
                    ivar_loop({princess, T, P})
	    end;
	{_, {put, NewT}} ->
	    if
		T == empty ->
		    try
			PredRes = P(NewT),
			if 
			    PredRes ->
				ivar_loop({princess, NewT, P});
			    (true) ->
				ivar_loop({princess, T, P})
			end
		    after
			ivar_loop({princess, T, P})
		    end;
		(true) ->
		    ivar_loop({princess, T, P})
 	    end;
	{From, compromised} ->
	    From ! {self(), false},
	    ivar_loop({princess, T, P})
    end.
