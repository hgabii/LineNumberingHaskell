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

-- B

addLineNumbersForBlocks :: [Block] -> [Block]
addLineNumbersForBlocks blocks = snd (callLineNumberAdding (1, blocks))

callLineNumberAdding :: (Int, [Block]) -> (Int, [Block])
callLineNumberAdding (n, []) = (n, []) 
callLineNumberAdding (n, (x:xs)) = 
    ( fst (addLineNumberGlobal (n, x)), 
      (snd (addLineNumberGlobal (n, x))) : (snd ( callLineNumberAdding (fst (addLineNumberGlobal (n, x)) ), xs ) ) )
    -- TODO: optimize

addLineNumberGlobal :: (Int, Block) -> (Int, Block)
addLineNumberGlobal (n, block)
    | (isCodeBlock block) = ( fst (addLineNumberToLinesB (n, block)), snd(addLineNumberToLinesB (n, block)))
    | otherwise = (n, block)

addLineNumberToLinesB :: 

addLineNumberB :: (Int, [Sting]) -> (Int, [String])
addLineNumberB (n, []) = (n, [])
addLineNumberB (n, (x:xs)) = (n + 1, ((show n) ++ "   " ++ x) : addLineNumberB (n + 1, xs))
-- addLineNumberToCodeBlock :: (Int, Block) -> (Int, Block)
-- addLineNumberToCodeBlock (n, CodeBlock attr code) 

main :: IO ()
main = do 
    putStrLn "Start"
    inputFile <- TIO.readFile "test.md"
    p <- runIOorExplode $ readMarkdown def inputFile
    s' <- runIOorExplode $ writeMarkdown (def { writerSetextHeaders = False }) $ addLineNumbersPerCodeBlock p
    TIO.writeFile "testA.md" s'

    Pandoc _ blocks <- runIOorExplode $ readMarkdown def inputFile

    putStrLn "End"

