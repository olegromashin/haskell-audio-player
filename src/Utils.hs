module Utils where

import Sound.OpenAL (HasGetter, get)

errorOnNothingM :: Monad m => String -> Maybe a -> m a
errorOnNothingM err Nothing = error err
errorOnNothingM _ (Just v) = return v

printGettable :: (HasGetter m a, Show a) => String -> m -> IO ()
printGettable msg d = get d >>= (putStrLn . (msg ++) . show)
