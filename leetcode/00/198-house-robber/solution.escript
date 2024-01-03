#!/usr/bin/env escript
%%! -sname solution

% a, b = 0, 0
% for x in nums:
%   t = max(a, b)
%   b = a + x
%   a = t

% a_1, b_1 = 0, 0
% a_2, b_2 = max(a_1, b_1), a_1 + x_1
% a_3, b_3 = max(a_2, b_2), a_2 + x_2
% a_3, b_3 = max(max(a_1, b_1), a_1 + x1), ...
-spec rob(Nums :: [integer()]) -> integer().
rob(Nums) ->
  [_, Value] = lists:foldl(fun (Num, [Prev, Highest]) -> [Highest, max(Highest, Num + Prev)] end, [0, 0], Nums),
  Value.

main(_) ->
  io:format("Result: ~p~n", [rob([1,2,3,1])]).

