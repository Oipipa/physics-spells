module CAS.Parser where

import CAS.AST
import Data.Functor.Identity (Identity)
import Data.Ratio ((%))
import Text.Parsec
import Text.Parsec.Expr
import Text.Parsec.Language (emptyDef)
import qualified Text.Parsec.Token as Tok
import Text.Parsec.String (Parser)

lexer :: Tok.TokenParser ()
lexer = Tok.makeTokenParser style
  where
    style :: Tok.LanguageDef ()
    style = emptyDef
      { Tok.identStart      = letter
      , Tok.identLetter     = alphaNum
      , Tok.opStart         = oneOf "+-*/^"
      , Tok.opLetter        = oneOf "+-*/^"
      , Tok.reservedOpNames = ["+", "-", "*", "/", "^"]
      , Tok.reservedNames   = []
      , Tok.caseSensitive   = True
      }

parens :: Parser a -> Parser a
parens = Tok.parens lexer

integer :: Parser Integer
integer = Tok.integer lexer

reservedOp :: String -> Parser ()
reservedOp = Tok.reservedOp lexer

identifier :: Parser String
identifier = Tok.identifier lexer

whiteSpace :: Parser ()
whiteSpace = Tok.whiteSpace lexer

expr :: Parser Expr
expr = buildExpressionParser table factor

table :: [[Operator String () Identity Expr]]
table =
  [ [ Prefix (reservedOp "-" *> pure Neg) ]
  , [ Infix  (reservedOp "^" *> pure Pow) AssocRight ]
  , [ Infix  (reservedOp "*" *> pure Mul) AssocLeft
    , Infix  (reservedOp "/" *> pure Div) AssocLeft ]
  , [ Infix  (reservedOp "+" *> pure Add) AssocLeft
    , Infix  (reservedOp "-" *> pure Sub) AssocLeft ]
  ]

factor :: Parser Expr
factor =
      parens expr
  <|> try fraction
  <|> (Const . toRational <$> integer)
  <|> (Var <$> identifier)

fraction :: Parser Expr
fraction = do
  n <- integer
  _ <- char '/'
  d <- integer
  return $ Const (n % d)

parseExpr :: String -> Either ParseError Expr
parseExpr = parse (whiteSpace *> expr <* eof) ""
