-- | The driver.  All of the talking to the outside world happens here, so
-- that the modules under @src@ can stay pure.
module Main (main) where

import Adts
import Parse
import RenderMarkdown
import Shuffle
import System.Environment (getArgs)
import System.IO

-- | The quiz files that make up the question bank.
quizFiles :: [FilePath]
quizFiles = [ "data/arrays-mcq-.xml"
            , "data/methods-and-driver.xml"
            , "data/introduction-and-loops.xml"
            ]

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
    Right questions -> writeDocuments (seedFrom arguments) questions

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
  writeShuffled seed questions 5
  writeShuffled seed questions 10
  writeShuffled seed questions (length questions)

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
