-- | Core data types for the quiz question bank.
--
-- A value of type 'Question' is a question that has already been imported
-- and normalised.  Note that 'questionCategory' is a plain 'Category' and
-- not a @Maybe Category@: a stored question that has no category cannot be
-- built at all, so the "every stored question must have a category" rule
-- from the assignment brief is enforced by the type rather than by a check
-- that we have to remember to run.
module Adts
  ( Category(..)
  , QuestionType(..)
  , Answer(..)
  , Question(..)
  , correctAnswers
  , describeQuestionType
  ) where

-- | The category a question belongs to, for example \"Arrays\".
--
-- This is a newtype rather than a bare 'String' so that a category cannot
-- be mixed up with the other strings floating around the program, such as
-- a question name or a piece of feedback.
newtype Category = Category { categoryName :: String }
  deriving (Eq, Ord, Show)

-- | The type of a question, taken from the @type@ attribute in the XML.
--
-- Only multiple choice questions have to be supported, but recording the
-- other types keeps the information rather than silently throwing it away.
data QuestionType = MultiChoice
                  | OtherType String
                  deriving (Eq, Show)

-- | One answer option belonging to a multiple choice question.
data Answer = Answer { answerText      :: String
                     , answerIsCorrect :: Bool
                     , answerFeedback  :: Maybe String
                     } deriving (Eq, Show)

-- | A question as it is stored in the question bank.
data Question = Question { questionType     :: QuestionType
                         , questionCategory :: Category
                         , questionName     :: Maybe String
                         , questionText     :: String
                         , questionAnswers  :: [Answer]
                         , questionFeedback :: Maybe String
                         } deriving (Eq, Show)

-- | The answers of a question that are marked as correct.
correctAnswers :: Question -> [Answer]
correctAnswers question = [ answer | answer <- questionAnswers question
                                   , answerIsCorrect answer ]

-- | A readable description of a question type, for use in reports.
describeQuestionType :: QuestionType -> String
describeQuestionType MultiChoice     = "multiple choice"
describeQuestionType (OtherType name) = name
