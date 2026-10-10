#!/bin/bash
# Gera libdivecomputer.so para cada ABI com o NDK (o mesmo CMakeLists.txt que o app usa; o alvo
# sbdivecomputer é o JNI do app e aqui não entra). Uso: ANDROID_NDK=/caminho/ndk ./build.sh
set -euo pipefail
cd "$(dirname "$0")"
: "${ANDROID_NDK:?defina ANDROID_NDK (ex.: ~/Library/Android/sdk/ndk/27.1.12297006)}"
for ABI in arm64-v8a armeabi-v7a x86_64 x86; do
  cmake -S . -B "build/$ABI" -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ABI" -DANDROID_PLATFORM=android-24 -DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON \
    -DLIBDC_SRC="$(pwd)/../libdivecomputer" >/dev/null
  cmake --build "build/$ABI" --target divecomputer >/dev/null
  echo "ok: build/$ABI/libdivecomputer.so"
done
