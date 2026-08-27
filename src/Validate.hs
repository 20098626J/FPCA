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
  , repeatedQuestions
  , describeFault
  , describeProblem
  ) where

import Adts
import Data.Either (partitionEithers)
import Data.List (intercalate, nub)

-- | Something that can be wrong with a question.
--
-- The first three are the invariants the brief lists.  The last three are
-- ones of our own: an answer option with nothing written on it, the same
-- option offered twice, and a category whose name is empty.  None of these
-- stops the program running, but each of them makes for a paper that a
-- student could not sensibly sit.
data Fault = NoQuestionText
           | NoAnswers
           | NoCorrectAnswer
           | BlankAnswerText
           | DuplicateAnswerText
           | BlankCategory
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
faultsIn question = textFaults ++ categoryFaults ++ answerFaults
  where
    answers = questionAnswers question
    texts   = [ answerText answer | answer <- answers ]

    textFaults
      | null (questionText question) = [NoQuestionText]
      | otherwise                    = []

    categoryFaults
      | null (categoryName (questionCategory question)) = [BlankCategory]
      | otherwise                                       = []

    -- A question of another type is not expected to carry answer options,
    -- so the answer rules only apply to multiple choice questions.
    answerFaults
      | questionType question /= MultiChoice = []
      | null answers                         = [NoAnswers]
      | otherwise = correctnessFault ++ blankFault ++ duplicateFault

    correctnessFault
      | null (correctAnswers question) = [NoCorrectAnswer]
      | otherwise                      = []

    blankFault
      | any null texts = [BlankAnswerText]
      | otherwise      = []

    duplicateFault
      | length (nub texts) /= length texts = [DuplicateAnswerText]
      | otherwise                          = []

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

-- | Questions that turn up more than once in a list.
--
-- This is a rule about a generated paper rather than about the bank: the
-- same question must not be asked twice on one paper.  Checking the output
-- as well as the input is the point - generation is supposed to make this
-- impossible, and this is what would notice if it ever stopped being true.
repeatedQuestions :: [Question] -> [Question]
repeatedQuestions questions =
  nub [ question | question <- questions, appearances question > 1 ]
  where
    appearances question =
      length [ other | other <- questions, other == question ]

-- | A fault in words.
describeFault :: Fault -> String
describeFault NoQuestionText      = "it has no question text"
describeFault NoAnswers           = "it is multiple choice but has no answers"
describeFault NoCorrectAnswer     = "it is multiple choice but no answer is correct"
describeFault BlankAnswerText     = "one of its answer options is blank"
describeFault DuplicateAnswerText = "the same answer option is offered twice"
describeFault BlankCategory       = "its category has no name"

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
