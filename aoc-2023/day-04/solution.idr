module Main

import Data.List
import Data.List1
import Data.Nat
import Data.Stream
import Data.String
import System
import System.File
import System.File.ReadWrite

fatal : Show err => err -> IO ()
fatal = die . show

-- can't get it to work; i give up
-- data Cards = (List Int, List Int)
-- data Cards = MkPair (List Int) (List Int)

unsafeParseInt : String -> Int
unsafeParseInt str =
  case parseInteger {a=Int} str of
    Just n => n
    Nothing => 0

-- parseLine : String -> Card
--
-- (winning numbers, my numbers)
parseLine : String -> (List Int, List Int)
parseLine line =
  let
    seg0 = split (== ':') line
    seg1 = last seg0
    segs = split (== '|') $ trim seg1
    wins = map unsafeParseInt . words $ head segs
    mine = map unsafeParseInt . words $ last segs
  in (wins, mine)

countMatches : (List Int, List Int) -> Nat
countMatches = length . uncurry intersect

-- ffs why... am I holding this wrong?
intpow : Int -> Nat -> Int
intpow a b = cast (power (cast a) b)

score : (List Int, List Int) -> Int
score cards =
  let
    c = countMatches cards
  in if c >= 1 then intpow 2 (pred c) else 0

pt1 : List String -> Int
pt1 ss = foldl (+) 0 $ map (score . parseLine) ss

expand : Nat -> (Nat, Nat) -> (Nat, Nat)
expand nhand0 (nmatch, nhand) = (nmatch, nhand0 + nhand)

evalOnce : List(Nat, Nat) -> List(Nat, Nat)
evalOnce ls =
  case ls of
    [] => []
    (nmatch, nhand) :: xs =>
      let
        -- expanded : List(Nat, Nat)
        expanded = map (expand nhand) $ take nmatch xs
        -- static : List(Int, Int)
        static = drop nmatch xs
      in expanded ++ static

evalAll : List(List Int, List Int) -> List(List(Nat, Nat))
evalAll cards =
  let
    -- matches : List(Nat)
    matches = map countMatches cards
    -- count : Nat
    count = length matches
    -- deck : List(Nat, Nat)
    deck = zip matches $ take count $ repeat 1
  in iterateN count evalOnce deck

-- I don't even care anymore
unsafePluck2 : List(Nat, Nat) -> Int
unsafePluck2 ls =
  case head' ls of
    Just((_, n)) => cast n
    Nothing => 0

pt2 : List String -> Int
pt2 ss =
  let
    -- evaluated : List(List(Nat, Nat))
    evaluated = evalAll $ map parseLine ss
  in sum $ map unsafePluck2 evaluated

main : IO ()
main = do
  (_ :: part :: filename :: _) <- getArgs
    | _ => fatal "Invalid argument?"
  Right raw <- readFile filename
    | Left err => fatal err
  -- printLn $ map parseLine $ lines raw
  printLn $ pt1 $ lines raw
  printLn $ pt2 $ lines raw
