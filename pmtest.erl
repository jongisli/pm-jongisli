-module(pmtest).
-include_lib("eunit/include/eunit.hrl").

-import(pm).
-import(pmuse).

start_ivars_test() ->
    V1 = pm:newVanilla(),
    V2 = pm:newVanilla(),
    P1 = pm:newPrincess(fun(_) -> true end),
    P2 = pm:newPrincess(fun(_) -> true end),
    true = is_process_alive(V1),
    true = is_process_alive(V2),
    true = is_process_alive(P1),
    true = is_process_alive(P2),
    ok.

put_get_vanilla_test() ->
    V = pm:newVanilla(),
    pm:put(V,42),
    42 = pm:get(V),
    ok.

put_get_princess_test() ->
    V = pm:newPrincess(fun(X) -> X > 10 end),
    pm:put(V,42),
    42 = pm:get(V),
    ok.

compromised_test() ->
    V = pm:newVanilla(),
    pm:put(V,42),
    false = pm:compromised(V),
    pm:put(V,c0mpr0miz0r),
    true = pm:compromised(V),
    ok.

pmmap_test() ->
    [0,1,2,3] = pmuse:pmmap(fun(N) -> N - 42 end, [42,43,44,45]),
    ok.
