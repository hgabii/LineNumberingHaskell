module Main where

--import Lib
import Text.Pandoc.Definition
import Text.Pandoc.Walk

import Text.Pandoc.Builder

import Text.Pandoc
import qualified Data.Text.IO as TIO
import qualified Data.Text as T
--import Data.Char (toUpper)

-- Global

isCodeBlock :: Block -> Bool
isCodeBlock (CodeBlock _ _) = True
isCodeBlock _               = False

-- A

addLineNumbersPerCodeBlock :: Pandoc -> Pandoc
addLineNumbersPerCodeBlock = walk callLineNumberAddingPerBlock

callLineNumberAddingPerBlock :: Block -> Block
callLineNumberAddingPerBlock x
    | isCodeBlock x = addLineNumberForCodeBlocks x
    | otherwise = x

addLineNumberForCodeBlocks :: Block -> Block
addLineNumberForCodeBlocks (CodeBlock attr code) = CodeBlock attr (addLineNumberToLines 1 code)
addLineNumberForCodeBlocks x = x

addLineNumberToLines :: Int -> String -> String
addLineNumberToLines n s = unlines (appendLineNumber n (lines s))

appendLineNumber :: Int -> [String] -> [String]
appendLineNumber _ [] = []
appendLineNumber n (x:xs) = ((show n) ++ "   " ++ x) : (appendLineNumber (n + 1) xs)

-- B and C

addLineNumbersForBlocks :: [Block] -> [Block]
addLineNumbersForBlocks blocks = snd (iterateBlocks (1, blocks))

iterateBlocks :: (Int, [Block]) -> (Int, [Block])
iterateBlocks (n, []) = (n, [])
iterateBlocks (n, (x:xs)) = (m , x' : (snd ( iterateBlocks (m, xs) )))
    where
        m = fst (addLineNumbersToBlock (n, x))
        x' = snd (addLineNumbersToBlock (n, x))

addLineNumbersToBlock :: (Int, Block) -> (Int, Block)
addLineNumbersToBlock (n, CodeBlock attr code) =
    (m, CodeBlock attr code')
        where
            m = fst (addLineNumberToCode (n, code))
            code' = snd (addLineNumberToCode (n, code))
addLineNumbersToBlock (n, block) = (n, block)

addLineNumberToCode :: (Int, String) -> (Int, String)
addLineNumberToCode (n, code) = 
    ( fst (codeLinesWithNumber), unlines (snd (codeLinesWithNumber)) )
    where
        codeLines = lines code
        codeLinesWithNumber = appendLineNumberB (n, codeLines)

appendLineNumberB :: (Int, [String]) -> (Int, [String])
appendLineNumberB (n, s) =  getFirstPartOfTripleTuple ( f (n, [], s) )
    where
        addNumberToStr :: Int -> String -> String
        addNumberToStr n s = (show n) ++ "   " ++ s
        f :: (Int, [String], [String]) -> (Int, [String], [String])
        f (n, result, []) = (n, result, [])
        f (n, result, (x:xs)) = f ( (n + 1), ( result ++ [(addNumberToStr n x)] ), (xs) )

getFirstPartOfTripleTuple :: (Int, [String], [String]) -> (Int, [String])
getFirstPartOfTripleTuple (n, x, y) = (n, x)
-- appendLineNumberB (n, []) = (n, [])
-- appendLineNumberB (n, (x:xs)) = 
--     (n + 1, (addNumberToStr n x) : ( snd ( appendLineNumberB ( (n + 1), xs ) ) ) )
--     where
--         addNumberToStr :: Int -> String -> String
--         addNumberToStr n s = (show n) ++ "   " ++ s

asList :: [String] -> String
asList ss = '[' : asList' ss
  where
    asList' (a:b:ss) = a ++ (',' : asList' (b:ss))
    asList' (a:ss)   = a ++ asList' (ss)
    asList' []       = "]"

main :: IO ()
main = do 
    putStrLn "Start"
    inputFile <- TIO.readFile "test.md"
    p <- runIOorExplode $ readMarkdown def inputFile
    s' <- runIOorExplode $ writeMarkdown (def { writerSetextHeaders = False }) $ addLineNumbersPerCodeBlock p
    TIO.writeFile "testA.md" s'

    Pandoc metaInf blocks <- runIOorExplode $ readMarkdown def inputFile
    b' <- runIOorExplode $ writeMarkdown (def { writerSetextHeaders = False }) $ Pandoc metaInf (addLineNumbersForBlocks blocks)
    
    TIO.writeFile "testB.md" b'
    putStrLn "End"

