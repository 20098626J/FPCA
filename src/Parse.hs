-- | Turning a parsed XML tree into questions.
--
-- 'Xml' knows about XML and nothing about quizzes; this module knows what
-- a Moodle quiz file means and nothing about how XML is read.
--
-- A quiz file is a @\<quiz\>@ element holding @\<question\>@ elements.  A
-- question whose type is @category@ is not a question at all: it sets the
-- default category for the questions that come after it, which is why the
-- questions have to be walked in order.
module Parse
  ( parseQuiz
  ) where

import Adts
import Data.Char (isSpace)
import Data.List (isPrefixOf)
import Xml

-- | Read the questions out of the contents of one quiz file.
parseQuiz :: String -> Either String [Question]
parseQuiz contents =
  case parseXml contents of
    Left err   -> Left err
    Right root ->
      case root of
        Element "quiz" _ _ -> collectQuestions Nothing (childrenNamed "question" root)
        _                  -> Left "the root element of a quiz file must be <quiz>"

-- | Walk the questions in order, remembering the default category most
-- recently set by a @\<question type=\"category\"\>@ element.
collectQuestions :: Maybe Category -> [Xml] -> Either String [Question]
collectQuestions _ [] = Right []
collectQuestions defaultCategory (element:rest)
  | typeName == "category" =
      collectQuestions (newDefault defaultCategory element) rest
  | otherwise =
      case defaultCategory of
        Nothing ->
          Left ("question " ++ describeQuestion element
                  ++ " has no category, and the file has not set a default category")
        Just category ->
          case buildQuestion category typeName element of
            Left err       -> Left err
            Right question -> addQuestion question (collectQuestions defaultCategory rest)
  where
    typeName = textOrEmpty (attributeValue "type" element)

-- | The default category after reading a category element.  A category
-- element we cannot make sense of leaves the current default alone.
newDefault :: Maybe Category -> Xml -> Maybe Category
newDefault current element =
  case categoryIn element of
    Nothing       -> current
    Just category -> Just category

-- | The category named by a @\<category\>\<text\>@ pair.
categoryIn :: Xml -> Maybe Category
categoryIn element =
  case firstChildNamed "category" element of
    Nothing              -> Nothing
    Just categoryElement ->
      case directText categoryElement of
        Nothing   -> Nothing
        Just name -> Just (Category (dropCoursePrefix name))

-- | Moodle writes categories as paths such as
-- @$course$\/Arrays\/Primitive_and_Object_Arrays@.  The @$course$@ and
-- @top@ parts say where the category lives rather than what it is called,
-- so they are dropped and the rest is kept exactly as written.
dropCoursePrefix :: String -> String
dropCoursePrefix name
  | "$course$/" `isPrefixOf` name = dropCoursePrefix (drop 9 name)
  | "top/"      `isPrefixOf` name = dropCoursePrefix (drop 4 name)
  | otherwise                     = name

-- | Build one question, given the category it belongs to.
buildQuestion :: Category -> String -> Xml -> Either String Question
buildQuestion category typeName element =
  case textIn "questiontext" element of
    Nothing   -> Left ("question " ++ describeQuestion element ++ " has no question text")
    Just text ->
      Right Question { questionType     = readQuestionType typeName
                     , questionCategory = category
                     , questionName     = textIn "name" element
                     , questionText     = text
                     , questionAnswers  = answersIn element
                     , questionFeedback = textIn "generalfeedback" element
                     }

-- | Recognise the one question type we have to support.
readQuestionType :: String -> QuestionType
readQuestionType "multichoice" = MultiChoice
readQuestionType other         = OtherType other

-- | Every @\<answer\>@ belonging to a question.
answersIn :: Xml -> [Answer]
answersIn element = [ toAnswer answer | answer <- childrenNamed "answer" element ]

-- | Read one answer.  An answer is correct when its fraction awards marks.
toAnswer :: Xml -> Answer
toAnswer element =
  Answer { answerText      = textOrEmpty (directText element)
         , answerIsCorrect = readFraction (textOrEmpty (attributeValue "fraction" element)) > 0
         , answerFeedback  = textIn "feedback" element
         }

-- | Read a fraction such as @\"100\"@.  Anything unreadable counts as zero
-- rather than bringing the program down, which is why this uses 'reads'
-- and not 'read'.
readFraction :: String -> Double
readFraction text =
  case reads (tidy text) of
    [(value, leftover)] | all isSpace leftover -> value
    _                                          -> 0

-- | The cleaned up text of the @\<text\>@ child of a named child element,
-- or Nothing when it is missing or blank.
textIn :: String -> Xml -> Maybe String
textIn childName element =
  case firstChildNamed childName element of
    Nothing    -> Nothing
    Just child -> directText child

-- | The cleaned up text of an element's own @\<text\>@ child.
directText :: Xml -> Maybe String
directText element =
  case firstChildNamed "text" element of
    Nothing          -> Nothing
    Just textElement ->
      case tidy (stripTags (textOf textElement)) of
        []   -> Nothing
        text -> Just text

-- | Drop HTML markup.  The sample files escape their markup inside the
-- text, so by this point @&lt;p&gt;@ has already become @\<p\>@ and would
-- otherwise show up in the generated Markdown.
stripTags :: String -> String
stripTags []         = []
stripTags ('<':rest) = stripTags (drop 1 (dropWhile (/= '>') rest))
stripTags (c:cs)     = c : stripTags cs

-- | Collapse runs of whitespace and trim the ends.
tidy :: String -> String
tidy text = unwords (words text)

-- | A question named in an error message.
describeQuestion :: Xml -> String
describeQuestion element =
  case textIn "name" element of
    Just name -> "\"" ++ name ++ "\""
    Nothing   -> "(unnamed)"

-- | An empty string stands in for missing text.
textOrEmpty :: Maybe String -> String
textOrEmpty Nothing     = ""
textOrEmpty (Just text) = text

-- | Put a question in front of the questions found by a later step.
addQuestion :: Question -> Either String [Question] -> Either String [Question]
addQuestion _        (Left err)        = Left err
addQuestion question (Right questions) = Right (question : questions)
