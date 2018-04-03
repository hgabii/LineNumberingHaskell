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

addLineNumbersForBlocks :: [Block] -> (Int, Int, [Block])
addLineNumbersForBlocks blocks = iterateBlocks (1, 0, blocks)

iterateBlocks :: (Int, Int, [Block]) -> (Int, Int, [Block])  -- use two block as input and output |in recursion call the function itself
iterateBlocks (n, nc, []) = (n, nc, [])
iterateBlocks (n, nc, (x:xs)) = (m , mc, x' : (thdBlockArray ( iterateBlocks (m, mc, xs) )))
    where
        m = fstBlock (addLineNumbersToBlock (n, nc, x))
        mc = sndBlock (addLineNumbersToBlock (n, nc, x))
        x' = thdBlock (addLineNumbersToBlock (n, nc, x))

addLineNumbersToBlock :: (Int, Int, Block) -> (Int, Int, Block)
addLineNumbersToBlock (n, nc, CodeBlock attr code) =
    (m, mc, CodeBlock attr code')
        where
            m = fst (addLineNumberToCode (n, code))
            mc = (nc + 1)
            code' = snd (addLineNumberToCode (n, code))
addLineNumbersToBlock (n, nc, block) = (n, nc, block)

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

fstBlock :: (Int, Int, Block) -> Int
fstBlock (f, _, _) = f

sndBlock :: (Int, Int, Block) -> Int
sndBlock (_, s, _) = s

thdBlock :: (Int, Int, Block) -> Block
thdBlock (_, _, t) = t

fstBlockArray :: (Int, Int, [Block]) -> Int
fstBlockArray (f, _, _) = f

sndBlockArray :: (Int, Int, [Block]) -> Int
sndBlockArray (_, s, _) = s

thdBlockArray :: (Int, Int, [Block]) -> [Block]
thdBlockArray (_, _, b) = b

-- For test
asList :: [String] -> String
asList ss = '[' : asList' ss
  where
    asList' (a:b:ss) = a ++ (',' : asList' (b:ss))
    asList' (a:ss)   = a ++ asList' (ss)
    asList' []       = "]"

writeOutTheResult :: (Int, Int, [Block]) -> Meta -> IO()
writeOutTheResult (lineNumbers, codeBlocks, blocks) meta = 
    do
        putStrLn ("Line numbers: " ++ (show lineNumbers))
        putStrLn ("Code blocks: " ++ (show codeBlocks))
        pan <- runIOorExplode $ writeMarkdown (def { writerSetextHeaders = False }) $ Pandoc meta blocks
        TIO.writeFile "testB.md" pan

main :: IO ()
main = do 
    putStrLn "Start"
    inputFile <- TIO.readFile "test.md"
    p <- runIOorExplode $ readMarkdown def inputFile
    s' <- runIOorExplode $ writeMarkdown (def { writerSetextHeaders = False }) $ addLineNumbersPerCodeBlock p
    TIO.writeFile "testA.md" s'

    Pandoc metaInf blocks <- runIOorExplode $ readMarkdown def inputFile
    -- b' <- runIOorExplode $ writeMarkdown (def { writerSetextHeaders = False }) $ Pandoc metaInf (thdBlockArray (addLineNumbersForBlocks blocks))
    writeOutTheResult (addLineNumbersForBlocks blocks) metaInf
    -- TIO.writeFile "testB.md" b'
    putStrLn "End"

