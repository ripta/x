#!/usr/bin/env stack
-- stack script --resolver lts-21.24

-- parseInts "1 12 30 4" -> [1, 12, 30, 4]
parseInts :: String -> [Integer]
parseInts = map read . words

-- intervalsWith (-) [1, 2, 3, 5, 8, 13] -> [1, 1, 2, 3, 5, 8]
intervalsWith :: (a -> a -> a) -> [a] -> [a]
intervalsWith op seq = zipWith op (tail seq) (init seq)

-- deltas [1, 2, 3, 5, 8, 13] -> [1, 1, 2, 3, 5, 8]
deltas :: Num a => [a] -> [a]
deltas = intervalsWith (-)

-- nonzeros [] -> False
-- nonzeros [0, 0, 0, 0] -> False
-- nonzeros [0, 0, 0, 1] -> True
nonzeros :: (Foldable t, Eq a, Num a) => t a -> Bool
nonzeros = any (/= 0)

-- deltaDepth
deltaDepth :: (Eq a, Num a) => [a] -> [[a]]
deltaDepth = takeWhile nonzeros . iterate deltas

calculateNext = foldr ((+) . last) 0 . reverse . deltaDepth

main = do raw <- getContents -- stdin
          let ints = map parseInts (lines raw)
          let nextUp = sum . map calculateNext $ ints
          putStrLn $ "Pt 1: " ++ (show nextUp)
          let prevDown = sum . map (calculateNext . reverse) $ ints
          putStrLn $ "Pt 2: " ++ (show prevDown)
