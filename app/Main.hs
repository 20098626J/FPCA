-- | The driver.  All of the talking to the outside world happens here, so
-- that the modules under @src@ can stay pure.
module Main (main) where

import Adts
import Parse
import RenderMarkdown
import System.IO

-- | The quiz files that make up the question bank.
quizFiles :: [FilePath]
quizFiles = [ "data/arrays-mcq-.xml"
            , "data/methods-and-driver.xml"
            , "data/introduction-and-loops.xml"
            ]

main :: IO ()
main = do
  hSetEncoding stdout utf8
  putStrLn "Quiz bank"
  putStrLn "========="
  contents <- readAll quizFiles
  case parseQuizFiles (zip quizFiles contents) of
    Left err        -> putStrLn ("could not build the question bank: " ++ err)
    Right questions -> writeDocuments questions

-- | Write out the Markdown documents asked for in parts B and C.
writeDocuments :: [Question] -> IO ()
writeDocuments questions = do
  putStrLn (show (length questions) ++ " questions read from "
              ++ show (length quizFiles) ++ " files.")
  putStrLn ""
  writeDocument "questions.md"
                (renderQuestions "Quiz Bank: Questions" questions)
  writeDocument "questions-and-answers.md"
                (renderQuestionsAndAnswers "Quiz Bank: Questions, Answers and Feedback"
                                           questions)

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
