-- | Shuffling, without any use of IO.
--
-- The module has not covered a random number library, so this is a small
-- generator written by hand.  Keeping it pure has two advantages: the same
-- seed always produces the same paper, so a generated paper can be handed
-- in and reproduced, and the shuffle is an ordinary function that can be
-- tested with QuickCheck rather than something hidden inside IO.
module Shuffle
  ( Seed
  , shuffle
  , shuffleTake
  ) where

-- | The state of the generator.  Starting from the same seed gives the
-- same shuffle every time.
type Seed = Int

-- | Put a list into a pseudo random order.
--
-- This is the usual selection shuffle: pick one item out of the list at
-- random, then shuffle whatever is left.  Because every step removes
-- exactly one item, the result is always a rearrangement of the input,
-- with nothing lost, added or duplicated.
shuffle :: Seed -> [a] -> [a]
shuffle _    []    = []
shuffle seed items =
  case removeAt index items of
    Nothing             -> items
    Just (chosen, rest) -> chosen : shuffle updated rest
  where
    (index, updated) = nextIndex seed (length items)

-- | Shuffle and then keep the first @n@ items, which is how a set of a
-- given size is drawn from the bank.  Asking for more than there is gives
-- back everything, in a shuffled order.
shuffleTake :: Seed -> Int -> [a] -> [a]
shuffleTake seed count items = take count (shuffle seed items)

-- | Take the item at a position out of a list, returning it and the rest.
-- Nothing when the position is past the end of the list.
removeAt :: Int -> [a] -> Maybe (a, [a])
removeAt _ []     = Nothing
removeAt 0 (x:xs) = Just (x, xs)
removeAt n (x:xs) =
  case removeAt (n - 1) xs of
    Nothing             -> Nothing
    Just (chosen, rest) -> Just (chosen, x : rest)

-- | The next seed in the sequence.
--
-- This is a linear congruential generator, using the multiplier and
-- increment given for one in Numerical Recipes.  It is not good enough for
-- anything that matters, but it is more than good enough for putting exam
-- questions in a different order.
nextSeed :: Seed -> Seed
nextSeed seed = (1664525 * seed + 1013904223) `mod` 2147483648

-- | A position in a list of the given size, and the seed to carry on with.
--
-- The higher bits of the seed are used rather than the lower ones: the low
-- bits of a generator of this kind repeat in a short cycle, so taking the
-- remainder of the seed itself would give a poor spread of positions.
nextIndex :: Seed -> Int -> (Int, Seed)
nextIndex seed count = ((updated `div` 65536) `mod` count, updated)
  where
    updated = nextSeed seed
