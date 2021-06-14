module Main where

import Control.Concurrent
import qualified Sound.ALUT.Initialization as ALUT.Init
import qualified Sound.ALUT.Loaders as ALUT
import Sound.OpenAL (genObjectName, get, ($=))
import qualified Sound.OpenAL as OAL
import qualified Sound.OpenAL.AL.Buffer as ALB
import qualified Sound.OpenAL.AL.Extensions as ALE
import qualified Sound.OpenAL.AL.Source as ALS
import qualified Sound.OpenAL.ALC.Context as ALCC
import qualified Sound.OpenAL.ALC.Device as ALCD
import qualified Sound.OpenAL.ALC.Errors as ALCE
import Utils (errorOnNothingM, printGettable)

main :: IO ()
main = runPlayer

runPlayer :: IO ()
runPlayer = ALUT.Init.withProgNameAndArgs ALUT.Init.runALUTUsingCurrentContext $ \_ _ -> do
  device <- runDevice
  context <- createContext device
  ALCC.currentContext $= Just context
  printGettable "OpenAL extensions: " ALE.alExtensions
  source <- createSource
  printGettable "Source listener: " (ALS.sourceRelative source)
  buffer <- ALUT.createBuffer $ ALUT.File "file-example-WAV.wav"
  printGettable "Current buffer data: " (ALB.bufferData buffer)
  ALS.queueBuffers source [buffer]
  printGettable "Current source type: " (ALS.sourceType source)
  printGettable "Current source looping mode: " (ALS.loopingMode source)
  ALS.buffersQueued source >>= print
  isFinished <- newEmptyMVar
  _ <- forkIO $ playAudio isFinished source
  readMVar isFinished
  ALS.buffersQueued source >>= print
  ALCC.currentContext $= Nothing
  ALCC.destroyContext context
  ALCD.closeDevice device
  pure ()

runDevice :: IO ALCD.Device
runDevice = do
  get ALCD.defaultDeviceSpecifier
    >>= errorOnNothingM "Couldn't find default device specifier."
    >>= (putStrLn . ("Default device specifier: " ++) . show)
  printGettable "List of devices: " ALCD.allDeviceSpecifiers
  mbDevice <- ALCD.openDevice Nothing
  device <- errorOnNothingM "Couldn't open device." mbDevice
  printGettable "List of errors after opening device: " (ALCE.alcErrors device)
  pure device

createContext :: ALCD.Device -> IO ALCC.Context
createContext device = do
  mbContext <- ALCC.createContext device []
  context <- errorOnNothingM "Couldn't create context." mbContext
  printGettable "List of errors after creating context: " (ALCE.alcErrors device)
  pure context

createSource :: IO ALS.Source
createSource = do
  source <- genObjectName
  printGettable "Source position: " (ALS.sourcePosition source)
  printGettable "Current source type: " (ALS.sourceType source)
  printGettable "Current source state: " (ALS.sourceState source)
  pure source

playAudio :: MVar () -> ALS.Source -> IO ()
playAudio isFinished source = do
  putStrLn "Playing the audio."
  ALS.play [source]
  waitUntilAudioPlayed isFinished source

waitUntilAudioPlayed :: MVar () -> ALS.Source -> IO ()
waitUntilAudioPlayed isFinished source = do
  sourceState <- get $ ALS.sourceState source
  if sourceState == ALS.Playing
    then waitUntilAudioPlayed isFinished source
    else putMVar isFinished ()
