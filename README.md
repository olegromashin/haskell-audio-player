# audio-player

## Hello World raw version of audio player written in Haskell.

Tested with .wav files only. For .mp3 you'll need an mp3 decoder.


Required libraries:
* `libopenal-dev` to use OpenAL package.
* [freealut](https://github.com/vancegroup/freealut) to use ALUT package.


Some links:
* [OpenAL example in C](https://ffainelli.github.io/openal-example/)
* [Using shared libraries in GHC](https://downloads.haskell.org/~ghc/7.4.1/docs/html/users_guide/using-shared-libs.html) - basically I just added `-dynamic` flag in package.yaml.
