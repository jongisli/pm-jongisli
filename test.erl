-module(test).
-export([test/0, test_pred/1, test_compromised/0]).
-import(pm).

test_pred(X) ->
    io:format("checking if ~p is less than 10~n", [X]),
    case X < 10 of
	true -> true;
	false -> false
    end.

test() ->
    V = pm:newPrincess(fun(_) -> true end),
    W = pm:newPrincess(fun(_) -> false end),
    Q = pm:newPrincess(fun test_pred/1),
    R = pm:newPrincess(fun(X) -> X+1 end),
    {pm:put(V,8), pm:put(W,8), pm:put(Q,8), pm:put(R,2)}.

test_compromised() ->
    V = pm:newVanilla(),
    Msg1 = pm:put(V,42),
    Msg2 = pm:compromised(V),
    Msg3 = pm:put(V,21),
    Msg4 = pm:compromised(V),
    {Msg1, Msg2, Msg3, Msg4}.
    
