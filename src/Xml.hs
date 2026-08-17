-- | A small XML reader, written by hand.
--
-- Only the part of XML that the Moodle quiz files actually use is covered:
-- a prolog, elements with attributes, self closing elements, text content
-- and character entities.  That is enough for the sample files and keeps
-- the reader to plain recursion over a 'String' using 'Data.List' and
-- 'Data.Char'.
--
-- Errors are reported with 'Either' rather than by calling 'error', so a
-- malformed file is a value the caller can report on instead of a crash.
module Xml
  ( Xml(..)
  , Attribute
  , parseXml
  , childrenNamed
  , firstChildNamed
  , attributeValue
  , textOf
  ) where

import Data.Char (chr, isAlphaNum, isDigit, isSpace)
import Data.List (isPrefixOf)

-- | An attribute is a name and its value, e.g. @(\"fraction\", \"100\")@.
type Attribute = (String, String)

-- | A parsed XML document is a tree of elements and text.
data Xml = Element String [Attribute] [Xml]
         | Text String
         deriving (Eq, Show)

-- | Read a whole XML document and return its root element.
parseXml :: String -> Either String Xml
parseXml input =
  case parseElement (skipIgnorable input) of
    Left err             -> Left err
    Right (element, rest)
      | all isSpace rest -> Right element
      | otherwise        -> Left ("unexpected content after the root element: "
                                    ++ preview rest)

-- | Skip whitespace, the @\<?xml ... ?\>@ prolog, comments and doctypes.
skipIgnorable :: String -> String
skipIgnorable input
  | "<?"   `isPrefixOf` trimmed = skipIgnorable (dropThrough "?>" trimmed)
  | "<!--" `isPrefixOf` trimmed = skipIgnorable (dropThrough "-->" trimmed)
  | "<!"   `isPrefixOf` trimmed = skipIgnorable (dropThrough ">" trimmed)
  | otherwise                   = trimmed
  where
    trimmed = dropWhile isSpace input

-- | Drop everything up to and including the given marker.
dropThrough :: String -> String -> String
dropThrough marker input
  | null input                = []
  | marker `isPrefixOf` input = drop (length marker) input
  | otherwise                 = dropThrough marker (drop 1 input)

-- | Read one element, returning it together with the unread input.
parseElement :: String -> Either String (Xml, String)
parseElement ('<':afterOpen)
  | null name = Left ("expected an element name at: " ++ preview afterOpen)
  | otherwise =
      case parseAttributes afterName of
        Left err -> Left err
        Right (attributes, afterAttributes)
          | "/>" `isPrefixOf` afterAttributes ->
              Right (Element name attributes [], drop 2 afterAttributes)
          | ">"  `isPrefixOf` afterAttributes ->
              case parseContent name (drop 1 afterAttributes) of
                Left err               -> Left err
                Right (children, rest) -> Right (Element name attributes children, rest)
          | otherwise ->
              Left ("malformed start tag for <" ++ name ++ "> at: "
                      ++ preview afterAttributes)
  where
    (name, afterName) = span isNameChar afterOpen
parseElement input = Left ("expected '<' at: " ++ preview input)

-- | Read the attributes of a start tag, stopping at @>@ or @\/>@.
parseAttributes :: String -> Either String ([Attribute], String)
parseAttributes input
  | "/>" `isPrefixOf` trimmed = Right ([], trimmed)
  | ">"  `isPrefixOf` trimmed = Right ([], trimmed)
  | null trimmed              = Left "unexpected end of input inside a start tag"
  | null name                 = Left ("expected an attribute name at: " ++ preview trimmed)
  | otherwise =
      case dropWhile isSpace afterName of
        ('=':afterEquals) ->
          case parseQuoted (dropWhile isSpace afterEquals) of
            Left err -> Left err
            Right (value, afterValue) ->
              case parseAttributes afterValue of
                Left err                    -> Left err
                Right (others, afterOthers) ->
                  Right ((name, decodeEntities value) : others, afterOthers)
        _ -> Left ("expected '=' after attribute " ++ name)
  where
    trimmed           = dropWhile isSpace input
    (name, afterName) = span isNameChar trimmed

-- | Read a quoted attribute value, allowing either quote character.
parseQuoted :: String -> Either String (String, String)
parseQuoted (quote:rest)
  | quote == '"' || quote == '\'' =
      case span (/= quote) rest of
        (value, closing:afterValue)
          | closing == quote -> Right (value, afterValue)
        _                    -> Left "unterminated attribute value"
parseQuoted input = Left ("expected a quoted attribute value at: " ++ preview input)

-- | Read the children of an element up to its closing tag.
parseContent :: String -> String -> Either String ([Xml], String)
parseContent name input
  | null input                 = Left ("missing closing tag for <" ++ name ++ ">")
  | closing `isPrefixOf` input = Right ([], drop (length closing) input)
  | "<!--" `isPrefixOf` input  = parseContent name (dropThrough "-->" input)
  | "<"    `isPrefixOf` input  =
      case parseElement input of
        Left err            -> Left err
        Right (child, rest) -> addChild child (parseContent name rest)
  | otherwise                  = addChild (Text (decodeEntities raw))
                                          (parseContent name afterText)
  where
    closing          = "</" ++ name ++ ">"
    (raw, afterText) = span (/= '<') input

-- | Put a child in front of the children found by a later parse step.
addChild :: Xml -> Either String ([Xml], String) -> Either String ([Xml], String)
addChild _     (Left err)               = Left err
addChild child (Right (children, rest)) = Right (child : children, rest)

-- | Replace XML character entities with the characters they stand for.
--
-- The sample files escape their HTML markup, so @&lt;p&gt;@ has to become
-- @\<p\>@ before the text is of any use.  An entity we do not recognise is
-- left exactly as it was rather than being silently dropped.
decodeEntities :: String -> String
decodeEntities [] = []
decodeEntities ('&':rest) =
  case span (/= ';') rest of
    (entity, ';':afterEntity) -> entityText entity ++ decodeEntities afterEntity
    _                         -> '&' : decodeEntities rest
decodeEntities (c:cs) = c : decodeEntities cs

-- | The text a named or numeric entity stands for.
entityText :: String -> String
entityText "lt"   = "<"
entityText "gt"   = ">"
entityText "amp"  = "&"
entityText "quot" = "\""
entityText "apos" = "'"
entityText ('#':digits)
  | not (null digits) && all isDigit digits = [chr (read digits)]
entityText other  = "&" ++ other ++ ";"

-- | Characters that may appear in an element or attribute name.
isNameChar :: Char -> Bool
isNameChar c = isAlphaNum c || c == '_' || c == '-' || c == ':' || c == '.'

-- | A short piece of the input, for use in error messages.
preview :: String -> String
preview input = take 40 (dropWhile isSpace input)

-- Walking a parsed tree --------------------------------------------------

-- | The direct children of an element that have the given name.
childrenNamed :: String -> Xml -> [Xml]
childrenNamed wanted (Element _ _ children) =
  [ child | child <- children, hasName wanted child ]
childrenNamed _ (Text _) = []

-- | The first child with the given name, if the element has one.
firstChildNamed :: String -> Xml -> Maybe Xml
firstChildNamed wanted node =
  case childrenNamed wanted node of
    []        -> Nothing
    (child:_) -> Just child

-- | The value of one of an element's attributes, if it has that attribute.
attributeValue :: String -> Xml -> Maybe String
attributeValue wanted (Element _ attributes _) = lookup wanted attributes
attributeValue _       (Text _)                = Nothing

-- | All of the text underneath a node, joined together.
textOf :: Xml -> String
textOf (Text text)             = text
textOf (Element _ _ children)  = concat [ textOf child | child <- children ]

-- | Does this node happen to be an element with the given name?
hasName :: String -> Xml -> Bool
hasName wanted (Element name _ _) = name == wanted
hasName _      (Text _)           = False
