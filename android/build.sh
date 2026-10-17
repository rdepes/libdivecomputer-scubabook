#!/bin/bash
# Gera libdivecomputer.so para cada ABI com o NDK (o mesmo CMakeLists.txt que o app usa; o alvo
# sbdivecomputer é o JNI do app e aqui não entra). Uso: ANDROID_NDK=/caminho/ndk ./build.sh
set -euo pipefail
cd "$(dirname "$0")"
: "${ANDROID_NDK:?defina ANDROID_NDK (ex.: ~/Library/Android/sdk/ndk/27.1.12297006)}"
# cmake: o do PATH ou o que vem com o SDK do Android (sdk/cmake/<versão>/bin); achado do ensaio de 16/10
CMAKE="${CMAKE:-$(command -v cmake || ls -d "$ANDROID_NDK"/../../cmake/*/bin/cmake 2>/dev/null | tail -1)}"
: "${CMAKE:?cmake não encontrado: instale (brew install cmake) ou o pacote CMake do SDK Manager}"
for ABI in arm64-v8a armeabi-v7a x86_64 x86; do
  "$CMAKE" -S . -B "build/$ABI" -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ABI" -DANDROID_PLATFORM=android-24 -DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON \
    -DLIBDC_SRC="$(pwd)/../libdivecomputer" >/dev/null
  "$CMAKE" --build "build/$ABI" --target divecomputer >/dev/null
  echo "ok: build/$ABI/libdivecomputer.so"
done
