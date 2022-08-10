# Telegram iOS Source Code Compilation Guide

* This version of telegram will show custom date in PeerInfoController
* A new [UnixTimeFetcher](submodules/TelegramCore/Sources/TelegramEngine/UnixTime/UnixTimeFetcher.swift) api added in to TelegramEngine
* You can review changes in [this pull request](https://github.com/0x384c0/Telegram-iOS/pull/3/files)

# Compilation Guide

1. Install Xcode (directly from https://developer.apple.com/download/more or using the App Store).
2. Clone the project from GitHub:

```
git clone --recursive -j8 https://github.com/0x384c0/Telegram-iOS.git
```

3. Adjust configuration parameters

```
mkdir -p $HOME/telegram-configuration
cp -R build-system/example-configuration/* $HOME/telegram-configuration/
```

- Modify the values in `variables.bzl`
- Replace the provisioning profiles in `provisioning` with valid files

4. (Optional) Create a build cache directory to speed up rebuilds

```
mkdir -p "$HOME/telegram-bazel-cache"
```

5. Build the app

```
python3 build-system/Make/Make.py \
    --cacheDir="$HOME/telegram-bazel-cache" \
    build \
    --configurationPath="$HOME/telegram-configuration" \
    --buildNumber=100001 \
    --configuration=release_universal
```

6. (Optional) Generate an Xcode project

```
python3 build-system/Make/Make.py \
    --cacheDir="$HOME/telegram-bazel-cache" \
    generateProject \
    --configurationPath="$HOME/telegram-configuration" \
    --disableExtensions
```

It is possible to generate a project that does not require any codesigning certificates to be installed: add `--disableProvisioningProfiles` flag:
```
python3 build-system/Make/Make.py \
    --cacheDir="$HOME/telegram-bazel-cache" \
    generateProject \
    --configurationPath="$HOME/telegram-configuration" \
    --disableExtensions \
    --disableProvisioningProfiles
```


Tip: use `--disableExtensions` when developing to speed up development by not building application extensions and the WatchOS app.


# Tips

Bazel is used to build the app. To simplify the development setup a helper script is provided (`build-system/Make/Make.py`). See help:

```
python3 build-system/Make/Make.py --help
python3 build-system/Make/Make.py build --help
python3 build-system/Make/Make.py generateProject --help
```

Bazel is automatically downloaded when running Make.py for the first time. If you wish to use your own build of Bazel, pass `--bazel=path-to-bazel`. If your Bazel version differs from that in `versions.json`, you may use `--overrideBazelVersion` to skip the version check.

Each release is built using specific Xcode and Bazel versions (see `versions.json`). The helper script checks the versions of installed software and reports an error if they don't match the ones specified in `versions.json`. There are flags that allow to bypass these checks:

```
python3 build-system/Make/Make.py --overrideBazelVersion build ... # Don't check the version of Bazel
python3 build-system/Make/Make.py --overrideXcodeVersion build ... # Don't check the version of Xcode
```
