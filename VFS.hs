import System.IO
import Data.List
import qualified System.Directory as Dir
import Control.Monad

data FileSystem = File String | Directory String [FileSystem]
  deriving (Show, Read, Eq)

data FSState = FSState {
  path :: [String],
  currentDir :: FileSystem
} deriving (Show)

-- Main loop
main :: IO ()
main = do
  let root = Directory "root" []
  repl $ FSState ["root"] root

-- Read-eval-print loop
repl :: FSState -> IO ()
repl state = do
  putStrLn $ "Current path: " ++ intercalate "/" (path state)
  putStrLn "Commands: ls, cd <dir>, mkdir <name>, touch <name>, rm <name>, edit <name>, save <file>, load <file>, exit"
  putStr ">> "
  hFlush stdout
  command <- getLine
  let (cmd:args) = words command ++ repeat ""
  case cmd of
    "ls" -> do
      listDir (currentDir state)
      repl state
    "cd" -> do
      let newState = changeDir (args !! 0) state
      repl newState
    "mkdir" -> do
      let newState = createDir (args !! 0) state
      repl newState
    "touch" -> do
      let newState = createFile (args !! 0) state
      repl newState
    "rm" -> do
      let newState = remove (args !! 0) state
      repl newState
    "edit" -> do
      newState <- editFile (args !! 0) state
      repl newState
    "save" -> do
      saveToFile (args !! 0) (currentDir state)
      repl state
    "load" -> do
      newFs <- loadFromFile (args !! 0)
      repl $ FSState ["root"] newFs
    "exit" -> return ()
    _ -> do
      putStrLn "Invalid command"
      repl state

-- Display contents of the current directory
listDir :: FileSystem -> IO ()
listDir (Directory _ contents) =
  forM_ contents $ \fs -> putStrLn $ case fs of
    File name -> name
    Directory name _ -> name ++ "/"
listDir _ = putStrLn "Cannot list contents of a file"

-- Navigate into directories
changeDir :: String -> FSState -> FSState
changeDir ".." state =
  if length (path state) > 1
    then state { path = init (path state), currentDir = findDir (init (path state)) (currentDir state) }
    else state
changeDir dir state =
  case findSubdir dir (currentDir state) of
    Just subdir -> state { path = path state ++ [dir], currentDir = subdir }
    Nothing -> state

findSubdir :: String -> FileSystem -> Maybe FileSystem
findSubdir name (Directory _ contents) = find match contents
  where match (Directory n _) = n == name
        match _ = False
findSubdir _ _ = Nothing

findDir :: [String] -> FileSystem -> FileSystem
findDir ["root"] fs = fs
findDir (dir:dirs) (Directory _ contents) =
  case findSubdir dir (Directory "" contents) of
    Just subdir -> findDir dirs subdir
    Nothing -> Directory "root" []

-- Create a new directory
createDir :: String -> FSState -> FSState
createDir name state =
  let updatedDir = addDir name (currentDir state)
  in state { currentDir = updatedDir }

addDir :: String -> FileSystem -> FileSystem
addDir name (Directory dName contents) =
  Directory dName (Directory name [] : contents)
addDir _ fs = fs

-- Create a new file
createFile :: String -> FSState -> FSState
createFile name state =
  let updatedDir = addFile name (currentDir state)
  in state { currentDir = updatedDir }

addFile :: String -> FileSystem -> FileSystem
addFile name (Directory dName contents) =
  Directory dName (File name : contents)
addFile _ fs = fs

-- Remove a file or directory
remove :: String -> FSState -> FSState
remove name state =
  let updatedDir = removeItem name (currentDir state)
  in state { currentDir = updatedDir }

removeItem :: String -> FileSystem -> FileSystem
removeItem name (Directory dName contents) =
  Directory dName (filter (not . match) contents)
  where match (File n) = n == name
        match (Directory n _) = n == name
removeItem _ fs = fs

-- Edit a file
editFile :: String -> FSState -> IO FSState
editFile name state = do
  let maybeFile = findFileCustom name (currentDir state)
  case maybeFile of
    Just (File _) -> do
      putStrLn "Enter new content:"
      content <- getLine
      let updatedDir = updateFile name content (currentDir state)
      return state { currentDir = updatedDir }
    _ -> do
      putStrLn "File not found"
      return state

findFileCustom :: String -> FileSystem -> Maybe FileSystem
findFileCustom name (Directory _ contents) = find match contents
  where match (File n) = n == name
        match _ = False
findFileCustom _ _ = Nothing

updateFile :: String -> String -> FileSystem -> FileSystem
updateFile name newContent (Directory dName contents) =
  Directory dName (map update contents)
  where update (File n) | n == name = File (name ++ " (updated: " ++ newContent ++ ")")
        update item = item
updateFile _ _ fs = fs

-- Save file system to a file
saveToFile :: FilePath -> FileSystem -> IO ()
saveToFile filePath fs = writeFile filePath (show fs)

-- Load file system from a file
loadFromFile :: FilePath -> IO FileSystem
loadFromFile filePath = do
  content <- readFile filePath
  return (read content :: FileSystem)
