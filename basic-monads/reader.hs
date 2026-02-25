{-# LANGUAGE ApplicativeDo #-}

import Control.Monad.Reader
import System.Environment
import Text.Printf (printf)

data Config where
  Config :: {verbose :: Bool, appName :: String} -> Config

type ConfigM = Reader Config

getConfig :: IO Config
getConfig = do
  appName <- getExecutablePath
  pure $ Config {verbose = True, appName}

main :: IO ()
main = do
  config <- getConfig
  let rv = runReader dumpConfig config
  putStrLn $ "(dumpConfig) > " ++ rv

getVerbosity :: ConfigM Bool
getVerbosity = do
  asks verbose

dumpConfig :: ConfigM String
dumpConfig = do
  Config {appName} <- ask
  verboseFlag <- getVerbosity
  pure $ printf "{ AppName: %s, Verbose: %s }" appName (show verboseFlag)
