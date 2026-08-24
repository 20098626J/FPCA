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
  , Marks
  , mkMarks
  , marksValue
  , oneMark
  , Answer(..)
  , Question(..)
  , correctAnswers
  , describeQuestionType
  , totalMarks
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

-- | The marks a question is worth.
--
-- The constructor is deliberately not exported.  'mkMarks' is the only way
-- to build one and it refuses anything that is not positive, so the "marks
-- are positive" invariant holds for every value of this type that exists,
-- rather than being something a later check has to catch.
newtype Marks = Marks Int
  deriving (Eq, Ord, Show)

-- | Build marks, or nothing at all when the number is not positive.
mkMarks :: Int -> Maybe Marks
mkMarks number
  | number > 0 = Just (Marks number)
  | otherwise  = Nothing

-- | The number of marks.
marksValue :: Marks -> Int
marksValue (Marks number) = number

-- | One mark: what a question is worth when it does not say otherwise.
oneMark :: Marks
oneMark = Marks 1

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
                         , questionMarks    :: Marks
                         } deriving (Eq, Show)

-- | The answers of a question that are marked as correct.
correctAnswers :: Question -> [Answer]
correctAnswers question = [ answer | answer <- questionAnswers question
                                   , answerIsCorrect answer ]

-- | The marks a set of questions comes to in total.
totalMarks :: [Question] -> Int
totalMarks questions = sum [ marksValue (questionMarks question) | question <- questions ]

-- | A readable description of a question type, for use in reports.
describeQuestionType :: QuestionType -> String
describeQuestionType MultiChoice     = "multiple choice"
describeQuestionType (OtherType name) = name
