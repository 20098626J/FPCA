-- | Generating a paper that satisfies a lecturer's requirements.
--
-- A specification says two things: how many questions must come from each
-- category, and what the paper must add up to in marks.  The total has to
-- be met exactly, so building a paper is a search rather than a filter:
-- the category minimums are taken first, and then a combination of the
-- remaining questions has to be found that makes the marks up exactly.
--
-- 'Paper' hides its constructor.  The only way to get one is through
-- 'generatePaper', which refuses to return a paper that does not satisfy
-- the specification it was asked for, so an invalid paper cannot be handed
-- on to the rest of the program by accident.
module GeneratePaper
  ( PaperSpec(..)
  , Paper
  , paperSpec
  , paperQuestions
  , PaperError(..)
  , generatePaper
  , satisfiesSpec
  , describePaperError
  ) where

import Adts
import Shuffle

-- | What a lecturer asks for: a least number of questions from each named
-- category, and the marks the whole paper must come to.
data PaperSpec = PaperSpec { specMinimums   :: [(Category, Int)]
                           , specTotalMarks :: Int
                           } deriving (Eq, Show)

-- | A paper, together with the specification it was built to satisfy.
data Paper = Paper { paperSpec      :: PaperSpec
                   , paperQuestions :: [Question]
                   } deriving (Eq, Show)

-- | Why a paper could not be built.
--
-- This is an ADT rather than a message so that the reason is a value the
-- program can examine, and so that every reason has to be handled.
data PaperError
  = NotEnoughQuestions Category Int Int
    -- ^ category, how many were wanted, how many the bank holds
  | MinimumsExceedTotal Int Int
    -- ^ marks the minimums already come to, the required total
  | NoCombinationReachesTotal Int Int
    -- ^ the required total, the marks the minimums come to
  deriving (Eq, Show)

-- | Build a paper from the bank, or say why it cannot be done.
generatePaper :: Seed -> PaperSpec -> [Question] -> Either PaperError Paper
generatePaper seed spec bank =
  case takeMinimums seed (specMinimums spec) bank of
    Left err -> Left err
    Right (required, remaining)
      | shortfall < 0 -> Left (MinimumsExceedTotal committed target)
      | otherwise     ->
          case chooseExactly shortfall (shuffle seed remaining) of
            Nothing    -> Left (NoCombinationReachesTotal target committed)
            Just topUp -> finish spec target committed
                                 (shuffle seed (required ++ topUp))
      where
        committed = totalMarks required
        shortfall = target - committed
  where
    target = specTotalMarks spec

-- | Hand back a paper only when it really does satisfy the specification.
--
-- The search above should already guarantee this.  Checking anyway is what
-- makes the hidden constructor worth having: it is the one place a Paper
-- can be built, so anything that holds a Paper knows it is a valid one.
finish :: PaperSpec -> Int -> Int -> [Question] -> Either PaperError Paper
finish spec target committed questions
  | satisfiesSpec spec questions = Right (Paper spec questions)
  | otherwise                    = Left (NoCombinationReachesTotal target committed)

-- | Take the least number of questions needed from each category, and
-- report what is left over for the rest of the paper to draw on.
takeMinimums :: Seed -> [(Category, Int)] -> [Question]
             -> Either PaperError ([Question], [Question])
takeMinimums _    []                        bank = Right ([], bank)
takeMinimums seed ((category, wanted):rest) bank
  | available < wanted = Left (NotEnoughQuestions category wanted available)
  | otherwise =
      case takeMinimums seed rest leftover of
        Left err                 -> Left err
        Right (later, remaining) -> Right (picked ++ later, remaining)
  where
    inCategory = [ question | question <- bank, questionCategory question == category ]
    available  = length inCategory
    picked     = take wanted (shuffle seed inCategory)
    leftover   = [ question | question <- bank, notElem question picked ]

-- | Find questions whose marks come to exactly the target.
--
-- Every question is worth at least one mark, so taking a question always
-- brings the target down and the search cannot run forever.  A question
-- worth more than what is left is skipped rather than tried, which keeps
-- the search small.
chooseExactly :: Int -> [Question] -> Maybe [Question]
chooseExactly 0      _         = Just []
chooseExactly _      []        = Nothing
chooseExactly target questions
  | totalMarks questions < target = Nothing
chooseExactly target (question:rest)
  | value <= target =
      case chooseExactly (target - value) rest of
        Just chosen -> Just (question : chosen)
        Nothing     -> chooseExactly target rest
  | otherwise = chooseExactly target rest
  where
    value = marksValue (questionMarks question)

-- | Does this set of questions meet the specification?
--
-- 'generatePaper' checks against this before returning, and the QuickCheck
-- properties use it to say what a successfully generated paper must be.
satisfiesSpec :: PaperSpec -> [Question] -> Bool
satisfiesSpec spec questions =
  totalMarks questions == specTotalMarks spec
    && and [ countInCategory category questions >= wanted
           | (category, wanted) <- specMinimums spec ]

-- | How many of these questions belong to a category.
countInCategory :: Category -> [Question] -> Int
countInCategory category questions =
  length [ question | question <- questions, questionCategory question == category ]

-- | Why a paper could not be built, in words a lecturer can act on.
describePaperError :: PaperError -> String
describePaperError (NotEnoughQuestions category wanted available) =
  "the paper needs at least " ++ show wanted ++ " question(s) from "
    ++ categoryName category ++ ", but the bank only holds " ++ show available
describePaperError (MinimumsExceedTotal committed target) =
  "the category minimums alone come to " ++ show committed
    ++ " marks, which is already more than the required total of " ++ show target
describePaperError (NoCombinationReachesTotal target committed) =
  "no combination of questions reaches exactly " ++ show target
    ++ " marks (the category minimums account for " ++ show committed ++ ")"
