-- | The driver.  All of the talking to the outside world happens here, so
-- that the modules under @src@ can stay pure.
module Main (main) where

import Adts
import Parse
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
  putStrLn "Quiz bank importer"
  putStrLn "=================="
  reportAll quizFiles

-- | Report on each quiz file in turn.
reportAll :: [FilePath] -> IO ()
reportAll []           = return ()
reportAll (path:paths) = do
  report path
  reportAll paths

-- | Read one quiz file and say what was found in it.
report :: FilePath -> IO ()
report path = do
  contents <- readUtf8 path
  putStrLn ""
  putStrLn path
  case parseQuiz contents of
    Left err        -> putStrLn ("  could not be read: " ++ err)
    Right questions -> do
      putStrLn ("  questions: " ++ show (length questions))
      putLines [ "  " ++ show number ++ ". " ++ summarise question
               | (number, question) <- numbered questions ]

-- | One line describing a question.
summarise :: Question -> String
summarise question =
  categoryName (questionCategory question) ++ " | " ++ shorten (questionText question)

-- | Keep a line short enough to read in a terminal.
shorten :: String -> String
shorten text
  | length text <= 60 = text
  | otherwise         = take 57 text ++ "..."

-- | Pair each item with its position, counting from one.
numbered :: [a] -> [(Int, a)]
numbered items = zip [1 .. ] items

-- | Write out a list of lines.
putLines :: [String] -> IO ()
putLines []           = return ()
putLines (first:rest) = do
  putStrLn first
  putLines rest

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
