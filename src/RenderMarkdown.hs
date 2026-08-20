-- | Turning questions into Markdown.
--
-- Two documents are produced, as asked for in the brief:
--
--   * a questions-only paper, which a student could sit;
--   * the same questions with their answers and feedback, which is the
--     version a lecturer would keep.
--
-- Both are built as a list of lines and joined at the end, so each piece
-- of the document is a small function that is easy to read on its own.
module RenderMarkdown
  ( renderQuestions
  , renderQuestionsAndAnswers
  ) where

import Adts
import Data.List (intercalate, nub)

-- | The questions on their own: numbered, with the text and the category.
renderQuestions :: String -> [Question] -> String
renderQuestions title questions =
  unlines (documentHeader title questions
             ++ concat [ questionBlock numbering | numbering <- numbered questions ])

-- | The questions together with their answer options, which of those are
-- correct, and any feedback.
renderQuestionsAndAnswers :: String -> [Question] -> String
renderQuestionsAndAnswers title questions =
  unlines (documentHeader title questions
             ++ concat [ questionBlock numbering ++ answerBlock (snd numbering)
                       | numbering <- numbered questions ])

-- | The title and a short summary of what is in the document.
documentHeader :: String -> [Question] -> [String]
documentHeader title questions =
  [ "# " ++ title
  , ""
  , show (length questions) ++ " questions across "
      ++ show (length categories) ++ " categories."
  , ""
  , "**Categories:** " ++ intercalate ", " [ categoryName c | c <- categories ]
  , ""
  , "---"
  , ""
  ]
  where
    categories = categoriesOf questions

-- | The categories used by these questions, in the order they first appear.
categoriesOf :: [Question] -> [Category]
categoriesOf questions = nub [ questionCategory question | question <- questions ]

-- | The heading, category and text of one question.
questionBlock :: (Int, Question) -> [String]
questionBlock (number, question) =
  [ "## " ++ show number ++ ". " ++ headingOf question
  , ""
  , "*Category: " ++ categoryName (questionCategory question) ++ "*"
  , ""
  , questionText question
  , ""
  ]

-- | The answer options of one question, with the correct ones ticked, and
-- any feedback underneath.
answerBlock :: Question -> [String]
answerBlock question =
  case questionAnswers question of
    []      -> [ "*This question has no answer options.*", "" ]
    answers -> [ "**Answers**", "" ]
                 ++ concat [ answerLines answer | answer <- answers ]
                 ++ [ "" ]
                 ++ feedbackLines question

-- | One answer option.  A ticked box marks a correct answer, which reads
-- sensibly as plain text and renders as a checkbox in a Markdown viewer.
answerLines :: Answer -> [String]
answerLines answer =
  ("- [" ++ box ++ "] " ++ answerText answer) : feedbackNote (answerFeedback answer)
  where
    box | answerIsCorrect answer = "x"
        | otherwise              = " "

-- | Feedback for a single answer, indented under it.
feedbackNote :: Maybe String -> [String]
feedbackNote Nothing         = []
feedbackNote (Just feedback) = [ "  - *" ++ feedback ++ "*" ]

-- | Feedback for the question as a whole, when it has any.
feedbackLines :: Question -> [String]
feedbackLines question =
  case questionFeedback question of
    Nothing       -> []
    Just feedback -> [ "**Feedback:** " ++ feedback, "" ]

-- | The heading for a question: its name when it has one, and otherwise
-- the question text itself.
headingOf :: Question -> String
headingOf question =
  case questionName question of
    Just name -> name
    Nothing   -> questionText question

-- | Pair each question with its position, counting from one.
numbered :: [a] -> [(Int, a)]
numbered items = zip [1 .. ] items
