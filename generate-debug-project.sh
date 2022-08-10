mkdir -p ../telegram-bazel-cach

python3 build-system/Make/Make.py \
    --cacheDir="../telegram-bazel-cache" \
    generateProject \
    --configurationPath="./build-system/debug-configuration" \
    --disableExtensions \
    --disableProvisioningProfiles