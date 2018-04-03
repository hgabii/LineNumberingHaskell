module Main where

import Text.Pandoc.Walk
import Text.Pandoc
import qualified Data.Text.IO as TextIO
import qualified Data.Text as Text
import Control.Monad.State

-- Global Functions

newId :: State Int Int
newId = state $ \s -> (s+1, s+1)

numberLine :: String -> State Int String
numberLine s = do
    i <- newId
    pure $ show i ++ "   " ++ s

appenNumbers s = mapM numberLine (lines s) 

-- A

addLineNumbersPerCodeBlock :: Pandoc -> Pandoc
addLineNumbersPerCodeBlock = walk lineNumberAddingPerBlock

lineNumberAddingPerBlock :: Block -> Block
lineNumberAddingPerBlock (CodeBlock attr code) = 
    CodeBlock attr ( unlines $ fst $ (runState (appenNumbers code) 0) )
lineNumberAddingPerBlock block = block

-- B, C, D

appendLineNumbersAndGetNumberOfLines :: Pandoc -> (Pandoc, Int)
appendLineNumbersAndGetNumberOfLines p = 
    runState (walkM addLineNumbersForBlockAndCountLines p) 0

appendLineNumbersAndGetNumberOfCodeBlocks :: Pandoc -> (Pandoc, Int)
appendLineNumbersAndGetNumberOfCodeBlocks p = 
    runState (walkM addLineNumbersForBlockAndCountBlocks p) 0

addLineNumbersForBlockAndCountLines :: Block -> State Int Block
addLineNumbersForBlockAndCountLines (CodeBlock attr code) = do
    numberOfLines <- get
    let codeWithLineNumber = unlines $ (evalState (appenNumbers code) numberOfLines)
    put (numberOfLines + length(lines code))
    return $ CodeBlock attr codeWithLineNumber
addLineNumbersForBlockAndCountLines block = return block

addLineNumbersForBlockAndCountBlocks :: Block -> State Int Block
addLineNumbersForBlockAndCountBlocks (CodeBlock attr code) = do
    (blocks) <- get
    let codeWithLineNumber = unlines $ (evalState (appenNumbers code) blocks)
    put (blocks + 1)
    return $ CodeBlock attr codeWithLineNumber
addLineNumbersForBlockAndCountBlocks block = return block

-- E, F
numberOfCharactersAndWords :: Pandoc -> (Int, Int)
numberOfCharactersAndWords p = execState (walkM countCharactersAndWords p) (0, 0)

countCharactersAndWords :: Inline -> State (Int, Int) Inline
countCharactersAndWords (Str l) = do
    (numberOfCharacters, numberOfWords) <- get
    put (numberOfCharacters + (length l), numberOfWords + 1)
    return (Str l)
countCharactersAndWords l = return l

main :: IO ()
main = do 
    -- Read text from file
    putStrLn "Type the name of the input file next to the executable: "
    fileName <- getLine
    inputText <- TextIO.readFile fileName
    p <- runIOorExplode $ readMarkdown (def {readerExtensions = pandocExtensions}) inputText
    -- A
    outputTextA <- runIOorExplode $ writeMarkdown (def { writerExtensions = pandocExtensions }) $ addLineNumbersPerCodeBlock p
    TextIO.writeFile "LineNumberingOutputA.md" outputTextA
    -- B, C, D
    let (pWithLineNumbers, lines) = appendLineNumbersAndGetNumberOfLines p
    let (notUsed, blocks) = appendLineNumbersAndGetNumberOfCodeBlocks p
    outputTextB <- runIOorExplode $ writeMarkdown (def {writerExtensions = pandocExtensions}) pWithLineNumbers
    TextIO.writeFile "LineNumberingOutputB.md" outputTextB
    putStrLn ("Line numbers: " ++ (show lines))
    putStrLn ("Code blocks: " ++ (show blocks))
    -- E, F
    let (characters, words) = numberOfCharactersAndWords p
    putStrLn ("Number of characters: " ++ (show characters))
    putStrLn ("Number of words: " ++ (show words))

