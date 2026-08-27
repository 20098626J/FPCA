-- | Property based tests.
--
-- QuickCheck cannot prove that the program is right.  What it can do is
-- try a rule against a few hundred generated cases and look for one that
-- breaks it, so the rules chosen here are the ones the brief names, and
-- each is checked against the real functions rather than against a
-- simplified copy of them.
--
-- Two of the bank invariants are deliberately absent.  "Every question has
-- a category" and "marks are positive" are carried by the types, so there
-- is no value QuickCheck could generate that breaks them; testing them
-- would be testing the compiler.
module Main (main) where

import Adts
import Data.List (sort)
import GeneratePaper
import Parse
import Shuffle
import System.Exit (exitFailure)
import Test.QuickCheck hiding (shuffle)
import Validate

-- Generators -------------------------------------------------------------

-- | A small pool of categories.
--
-- Keeping it small matters.  If every generated question had a category of
-- its own then a specification asking for two questions from one category
-- would almost never be satisfiable, generation would refuse every time,
-- and the paper properties would pass without ever testing anything.
categoryNames :: [String]
categoryNames = ["Introduction", "Loops", "Arrays"]

genCategoryName :: Gen String
genCategoryName = elements categoryNames

-- | A few words of text.
genText :: Gen String
genText = do
  count <- choose (1, 6)
  parts <- vectorOf count (elements ["what", "is", "the", "value", "of", "this", "code"])
  return (unwords parts)

-- | Marks between one and three.
genMarks :: Gen Marks
genMarks = do
  number <- choose (1, 3)
  case mkMarks number of
    Just marks -> return marks
    Nothing    -> return oneMark

-- | An answer, correct or otherwise.
genAnswer :: Bool -> Gen Answer
genAnswer correct = do
  text <- genText
  return Answer { answerText      = text
                , answerIsCorrect = correct
                , answerFeedback  = Nothing
                }

-- | A question that obeys the bank invariants: it has text, it has
-- answers, and exactly one of them is correct.
genQuestion :: Gen Question
genQuestion = do
  name      <- genCategoryName
  text      <- genText
  marks     <- genMarks
  wrongs    <- choose (1, 3)
  wrongOnes <- vectorOf wrongs (genAnswer False)
  rightOne  <- genAnswer True
  return Question { questionType     = MultiChoice
                  , questionCategory = Category name
                  , questionName     = Nothing
                  , questionText     = text
                  , questionAnswers  = rightOne : wrongOnes
                  , questionFeedback = Nothing
                  , questionMarks    = marks
                  }

-- | A bank with at least one question in it.
genBank :: Gen [Question]
genBank = do
  count <- choose (1, 12)
  vectorOf count genQuestion

-- | A specification that the given bank can satisfy.
--
-- It is built backwards from a selection out of the bank, so the minimums
-- and the total are taken from questions that are really there.  A paper
-- meeting the specification is therefore known to exist before generation
-- is asked to find one.
genSpecFor :: [Question] -> Gen PaperSpec
genSpecFor bank = do
  selection <- sublistOf bank
  let chosen   = if null selection then take 1 bank else selection
      minimums = [ (category, countIn category chosen)
                 | category <- categoriesOf chosen ]
  return PaperSpec { specMinimums   = minimums
                   , specTotalMarks = totalMarks chosen
                   }

-- | How many of these questions are in a category.
countIn :: Category -> [Question] -> Int
countIn category questions =
  length [ question | question <- questions, questionCategory question == category ]

-- | The categories these questions use, without repeats.
categoriesOf :: [Question] -> [Category]
categoriesOf questions = unique [ questionCategory question | question <- questions ]

unique :: Eq a => [a] -> [a]
unique []       = []
unique (x:rest) = x : unique [ other | other <- rest, other /= x ]

-- | A quiz file, as text, with a default category and one question for
-- each entry in the list.  An entry of Nothing means that question names
-- no category of its own and should inherit the default.
quizXml :: String -> [Maybe String] -> String
quizXml defaultCategory owners =
  unlines ([ "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
           , "<quiz>"
           , "  <question type=\"category\">"
           , "    <category><text>$course$/" ++ defaultCategory ++ "</text></category>"
           , "  </question>"
           ]
           ++ concat [ questionXml number owner
                     | (number, owner) <- zip [1 :: Int ..] owners ]
           ++ [ "</quiz>" ])

-- | One question inside a generated quiz file.
questionXml :: Int -> Maybe String -> [String]
questionXml number owner =
  [ "  <question type=\"multichoice\">" ]
    ++ ownCategory
    ++ [ "    <name><text>Q" ++ show number ++ "</text></name>"
       , "    <questiontext><text>Question " ++ show number ++ "</text></questiontext>"
       , "    <defaultgrade>1</defaultgrade>"
       , "    <answer fraction=\"100\"><text>Right</text></answer>"
       , "    <answer fraction=\"0\"><text>Wrong</text></answer>"
       , "  </question>"
       ]
  where
    ownCategory =
      case owner of
        Nothing   -> []
        Just name -> [ "    <category><text>$course$/" ++ name ++ "</text></category>" ]

-- | A list of questions, each either inheriting or naming a category.
genOwners :: Gen [Maybe String]
genOwners = listOf1 (oneof [ return Nothing, fmap Just genCategoryName ])

-- Properties -------------------------------------------------------------

-- | Shuffling does not change how many questions there are.
prop_shuffleKeepsCount :: Int -> [Int] -> Bool
prop_shuffleKeepsCount seed items = length (shuffle seed items) == length items

-- | Shuffling rearranges the questions and does nothing else: nothing is
-- lost, added or duplicated.
prop_shuffleKeepsItems :: Int -> [Int] -> Bool
prop_shuffleKeepsItems seed items = sort (shuffle seed items) == sort items

-- | Asking for a set of a given size gives that many questions, unless the
-- bank holds fewer, in which case it gives all of them.
prop_shuffleTakeSize :: Int -> Int -> [Int] -> Bool
prop_shuffleTakeSize seed count items =
  length (shuffleTake seed count items) == min (max 0 count) (length items)

-- | A question with no category of its own inherits the default of its
-- file, and a question that names one uses that instead.
--
-- This goes through the real parser on real XML text rather than testing a
-- copy of the rule.
prop_categoryRule :: Property
prop_categoryRule =
  forAll genCategoryName $ \defaultCategory ->
  forAll genOwners       $ \owners ->
    case parseQuiz (quizXml defaultCategory owners) of
      Left _          -> False
      Right questions ->
        length questions == length owners
          && and [ categoryName (questionCategory question) == wanted
                 | (question, owner) <- zip questions owners
                 , let wanted = case owner of
                                  Nothing   -> defaultCategory
                                  Just name -> name
                 ]

-- | Everything the parser accepts passes the bank invariants.
prop_parsedQuestionsAreSound :: Property
prop_parsedQuestionsAreSound =
  forAll genCategoryName $ \defaultCategory ->
  forAll genOwners       $ \owners ->
    case parseQuiz (quizXml defaultCategory owners) of
      Left _          -> False
      Right questions -> null (fst (checkBank questions))

-- | Marks can only be built from a positive number, and they keep the
-- number they were built from.
prop_marksArePositive :: Int -> Bool
prop_marksArePositive number =
  case mkMarks number of
    Nothing    -> number <= 0
    Just marks -> number > 0 && marksValue marks == number

-- | A paper that is generated satisfies the specification it was asked
-- for: every category minimum is met, and the marks come to exactly the
-- required total.
--
-- Refusals are counted and reported rather than passed over quietly, so it
-- stays visible that the property is not passing merely because generation
-- gives up every time.
prop_paperMeetsSpec :: Property
prop_paperMeetsSpec =
  forAll (choose (0, 100000)) $ \seed ->
  forAll genBank              $ \bank ->
  forAll (genSpecFor bank)    $ \spec ->
    let outcome = generatePaper seed spec bank
    in classify (refused outcome) "specification refused" $
       case outcome of
         Left _      -> True
         Right paper -> satisfiesSpec spec (paperQuestions paper)
  where
    refused (Left _)  = True
    refused (Right _) = False

-- | A generated paper only ever holds questions that came from the bank.
prop_paperComesFromBank :: Property
prop_paperComesFromBank =
  forAll (choose (0, 100000)) $ \seed ->
  forAll genBank              $ \bank ->
  forAll (genSpecFor bank)    $ \spec ->
    case generatePaper seed spec bank of
      Left _      -> True
      Right paper -> and [ elem question bank | question <- paperQuestions paper ]

-- Running ----------------------------------------------------------------

-- | Every property, with the name to print for it.
checks :: [(String, Property)]
checks =
  [ ("shuffling keeps the number of questions", property prop_shuffleKeepsCount)
  , ("shuffling keeps the same questions",      property prop_shuffleKeepsItems)
  , ("a shuffled set is the size asked for",    property prop_shuffleTakeSize)
  , ("a missing category inherits the default", property prop_categoryRule)
  , ("parsed questions pass the invariants",    property prop_parsedQuestionsAreSound)
  , ("marks are positive or are not built",     property prop_marksArePositive)
  , ("a generated paper meets its spec",        property prop_paperMeetsSpec)
  , ("a generated paper comes from the bank",   property prop_paperComesFromBank)
  ]

main :: IO ()
main = do
  passed <- runChecks checks
  if passed
    then putStrLn "all properties held"
    else exitFailure

-- | Run each property, reporting as it goes, and say whether all held.
runChecks :: [(String, Property)] -> IO Bool
runChecks []                    = return True
runChecks ((name, prop) : rest) = do
  putStrLn ("-- " ++ name)
  result <- quickCheckResult prop
  others <- runChecks rest
  return (isSuccess result && others)
