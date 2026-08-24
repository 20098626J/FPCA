-- | Checking that the question bank obeys its invariants.
--
-- The brief lists five invariants for the bank.  Two of them are already
-- impossible to break and so do not appear here:
--
--   * /every stored question has a category/ holds because
--     'questionCategory' is a 'Category' rather than a @Maybe Category@,
--     so a question without one cannot be built;
--   * /marks are positive/ holds because 'Marks' hides its constructor and
--     'mkMarks' refuses anything that is not positive.
--
-- That leaves three that a value can break, and they are what this module
-- looks for.  Checking is separate from parsing on purpose: parsing says
-- what a file contains, and this says whether what it contains is usable.
module Validate
  ( Fault(..)
  , Problem(..)
  , faultsIn
  , checkBank
  , describeFault
  , describeProblem
  ) where

import Adts
import Data.Either (partitionEithers)
import Data.List (intercalate)

-- | Something that can be wrong with a question.
data Fault = NoQuestionText
           | NoAnswers
           | NoCorrectAnswer
           deriving (Eq, Show)

-- | A question together with everything found wrong with it.
data Problem = Problem { problemFaults   :: [Fault]
                       , problemQuestion :: Question
                       } deriving (Eq, Show)

-- | Every fault a question has.
--
-- The two answer rules only apply to multiple choice questions, because a
-- question of another type is not expected to carry answer options.
faultsIn :: Question -> [Fault]
faultsIn question = textFaults ++ answerFaults
  where
    textFaults
      | null (questionText question) = [NoQuestionText]
      | otherwise                    = []
    answerFaults
      | questionType question /= MultiChoice = []
      | null (questionAnswers question)      = [NoAnswers]
      | null (correctAnswers question)       = [NoCorrectAnswer]
      | otherwise                            = []

-- | Split a bank into the problems found and the questions that are sound.
--
-- Every question is checked, rather than stopping at the first bad one, so
-- that a report can list everything that needs fixing in one go.
checkBank :: [Question] -> ([Problem], [Question])
checkBank questions = partitionEithers [ check question | question <- questions ]
  where
    check question =
      case faultsIn question of
        []     -> Right question
        faults -> Left (Problem faults question)

-- | A fault in words.
describeFault :: Fault -> String
describeFault NoQuestionText  = "it has no question text"
describeFault NoAnswers       = "it is multiple choice but has no answers"
describeFault NoCorrectAnswer = "it is multiple choice but no answer is correct"

-- | A problem in words, naming the question it belongs to.
describeProblem :: Problem -> String
describeProblem problem =
  nameOf (problemQuestion problem) ++ ": "
    ++ intercalate "; " [ describeFault fault | fault <- problemFaults problem ]

-- | How a question is referred to in a report.
nameOf :: Question -> String
nameOf question =
  case questionName question of
    Just name -> name
    Nothing   -> shorten (questionText question)

-- | Keep an identifier short enough to read.
shorten :: String -> String
shorten text
  | length text <= 50 = text
  | otherwise         = take 47 text ++ "..."
