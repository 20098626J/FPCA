-- | The driver.  All of the talking to the outside world happens here, so
-- that the modules under @src@ can stay pure.
module Main (main) where

import Adts
import GeneratePaper
import Parse
import RenderMarkdown
import Shuffle
import Validate
import System.Environment (getArgs)
import System.IO

-- | The quiz files that make up the question bank.
quizFiles :: [FilePath]
quizFiles = [ "data/arrays-mcq-.xml"
            , "data/methods-and-driver.xml"
            , "data/introduction-and-loops.xml"
            ]

-- | The paper a lecturer has asked for.
--
-- The brief gives an example asking for a least number of questions from
-- each of several categories and a total of 20 marks.  This is that
-- example, using the categories this question bank actually holds.
wantedPaper :: PaperSpec
wantedPaper = PaperSpec
  { specMinimums   = [ (Category "Arrays/Primitive_and_Object_Arrays", 2)
                     , (Category "Methods and Driver", 3)
                     , (Category "Loops", 2)
                     ]
  , specTotalMarks = 20
  }

-- | A specification the bank cannot satisfy, kept so that a run shows what
-- failing clearly looks like as well as what succeeding looks like.
impossiblePaper :: PaperSpec
impossiblePaper = PaperSpec
  { specMinimums   = [ (Category "Loops", 10) ]
  , specTotalMarks = 20
  }

-- | The seed used when none is given on the command line.  Having a
-- default keeps a plain run repeatable, which matters when the generated
-- papers are handed in.
defaultSeed :: Seed
defaultSeed = 20098626

main :: IO ()
main = do
  hSetEncoding stdout utf8
  arguments <- getArgs
  putStrLn "Quiz bank"
  putStrLn "========="
  contents <- readAll quizFiles
  case parseQuizFiles (zip quizFiles contents) of
    Left err        -> putStrLn ("could not build the question bank: " ++ err)
    Right questions -> do
      let (problems, sound) = checkBank questions
      reportProblems problems
      writeDocuments (seedFrom arguments) sound

-- | Say which questions failed the bank invariants.  A question that fails
-- is left out of the bank rather than being written into a paper.
reportProblems :: [Problem] -> IO ()
reportProblems [] = putStrLn "all questions passed the bank invariants."
reportProblems problems = do
  putStrLn (show (length problems)
              ++ " question(s) failed the bank invariants and were left out:")
  putLines [ "  - " ++ describeProblem problem | problem <- problems ]

-- | Write out a list of lines.
putLines :: [String] -> IO ()
putLines []             = return ()
putLines (first : rest) = do
  putStrLn first
  putLines rest

-- | The seed to shuffle with: the first argument when one is given and can
-- be read as a number, and the default otherwise.
seedFrom :: [String] -> Seed
seedFrom []          = defaultSeed
seedFrom (given : _) =
  case reads given of
    [(value, "")] -> value
    _             -> defaultSeed

-- | Write out the Markdown documents asked for in parts B, C and D.
writeDocuments :: Seed -> [Question] -> IO ()
writeDocuments seed questions = do
  putStrLn (show (length questions) ++ " questions read from "
              ++ show (length quizFiles) ++ " files.")
  putStrLn ("shuffling with seed " ++ show seed
              ++ " (pass a different one as an argument)")
  putStrLn ""
  writeDocument "questions.md"
                (renderQuestions "Quiz Bank: Questions" questions)
  writeDocument "questions-and-answers.md"
                (renderQuestionsAndAnswers "Quiz Bank: Questions, Answers and Feedback"
                                           questions)
  writePaper seed wantedPaper questions
  reportImpossible seed questions
  writeShuffled seed questions 5
  writeShuffled seed questions 10
  writeShuffled seed questions (length questions)

-- | Generate a paper meeting the specification and write it out.
writePaper :: Seed -> PaperSpec -> [Question] -> IO ()
writePaper seed spec questions =
  case generatePaper seed spec questions of
    Left err    -> putStrLn ("could not generate the paper: " ++ describePaperError err)
    Right paper ->
      writeDocument "paper.md"
                    (renderQuestions ("Generated Paper: " ++ show (specTotalMarks spec)
                                        ++ " marks (seed " ++ show seed ++ ")")
                                     (paperQuestions paper))

-- | Show what happens when a specification cannot be met.
reportImpossible :: Seed -> [Question] -> IO ()
reportImpossible seed questions = do
  putStrLn ""
  putStrLn "asking for a paper the bank cannot provide:"
  case generatePaper seed impossiblePaper questions of
    Left err -> putStrLn ("  refused: " ++ describePaperError err)
    Right _  -> putStrLn "  unexpectedly succeeded"
  putStrLn ""

-- | Write one shuffled set of the given size.
writeShuffled :: Seed -> [Question] -> Int -> IO ()
writeShuffled seed questions count =
  writeDocument ("shuffled-" ++ show count ++ ".md")
                (renderQuestions title (shuffleTake seed count questions))
  where
    title = "Shuffled Question Set: " ++ show count ++ " questions (seed "
              ++ show seed ++ ")"

-- | Write one document and say so.
writeDocument :: FilePath -> String -> IO ()
writeDocument path text = do
  writeUtf8 path text
  putStrLn ("wrote " ++ path)

-- | Read every quiz file, keeping them in the order they were given.
readAll :: [FilePath] -> IO [String]
readAll []           = return []
readAll (path:paths) = do
  contents <- readUtf8 path
  rest     <- readAll paths
  return (contents : rest)

-- | Read a file as UTF-8.
--
-- Plain 'readFile' would use whatever encoding the machine is set to,
-- which on Windows is not UTF-8, and the sample files contain characters
-- (such as an en dash) that would then be read incorrectly.
--
-- The handle is left for the runtime to close when the program ends,
-- because 'hGetContents' reads the file lazily and closing the handle here
-- would throw the contents away before they had been used.
readUtf8 :: FilePath -> IO String
readUtf8 path = do
  handle <- openFile path ReadMode
  hSetEncoding handle utf8
  hGetContents handle

-- | Write a file as UTF-8, for the same reason that files are read as UTF-8.
writeUtf8 :: FilePath -> String -> IO ()
writeUtf8 path text = do
  handle <- openFile path WriteMode
  hSetEncoding handle utf8
  hPutStr handle text
  hClose handle
