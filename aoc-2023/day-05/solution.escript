#!/usr/bin/env escript
%%! -sname solution
-mode(compile).

main([Filename]) ->
  {ok, Raw} = file:read_file(Filename),
  Lines = binary:split(Raw, <<"\n">>, [global, trim_all]),
  Result = parse(Lines),
  io:format("Result: ~p~n", [Result]).

parse([SeedDescription | RestLines]) ->
  Seeds = parse_seeds(SeedDescription),
  {FeatureMaps, _} = lists:foldl(fun parse_map/2, {#{}, undefined}, RestLines),
  %io:format("~p~n~n", [FeatureMaps]),
  lists:min(lookup_all(FeatureMaps, Seeds)).

lookup(_, location, Value) -> Value;
lookup(FeatureMaps, SrcType, Value) ->
  #{SrcType := FeatureMap, {SrcType, to} := DestType} = FeatureMaps,
  %io:format("~n~p ~p -> ~p", [SrcType, Value, DestType]),
  lookup(FeatureMaps, DestType, next_value(FeatureMap, Value)).

lookup_all(FeatureMaps, Seeds) -> [lookup(FeatureMaps, seed, Seed) || Seed <- Seeds].

next_value([], Value) ->
  %io:format(" ~p (fallback)", [Value]),
  Value;
next_value([{DestStart, SrcStart, SrcLength} | _], Value) when Value >= SrcStart, Value < SrcStart + SrcLength ->
  %io:format(" ~p", [DestStart - SrcStart + Value]),
  DestStart - SrcStart + Value;
next_value([_ | Rest], Value) -> next_value(Rest, Value).

parse_seeds(<<"seeds: ", Seeds/binary>>) -> parse_ints(Seeds).

parse_map(<<Digit:8, _/binary>> = Line, {FeatureMaps, Current}) when Digit >= $0, Digit =< $9 ->
  [DestStart, SrcStart, SrcLength] = parse_ints(Line),
  {FeatureMaps#{
    Current => [{DestStart, SrcStart, SrcLength} | maps:get(Current, FeatureMaps)]
  }, Current};
parse_map(FeatureMapHeading, {FeatureMaps, _}) ->
  [FromBinary, <<"to-", Rest/binary>>] = binary:split(FeatureMapHeading, <<"-">>),
  [ToBinary, _] = binary:split(Rest, <<" ">>),
  FromNum = binary_to_atom(FromBinary),
  ToNum = binary_to_atom(ToBinary),
  {FeatureMaps#{ {FromNum, to} => ToNum, FromNum => [] }, FromNum}.

parse_int(Binary) -> parse_int(Binary, 0).

parse_int(<<Digit:8, Rest/binary>>, Acc) when Digit >= $0, Digit =< $9 ->
  parse_int(Rest, Acc * 10 + Digit - $0);
parse_int(Binary, Acc) -> {Acc, Binary}.

parse_ints(Binary) -> parse_ints(Binary, []).

parse_ints(<<>>, Acc) -> lists:reverse(Acc);
parse_ints(<<" ", Binary/binary>>, Acc) -> parse_ints(Binary, Acc);
parse_ints(Binary, Acc) ->
  {Num, Rest} = parse_int(Binary),
  parse_ints(Rest, [Num | Acc]).
