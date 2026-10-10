#!/bin/bash
# Gera o LibDiveComputer.xcframework (biblioteca DINÂMICA) a partir da cópia de fonte em ../libdivecomputer/ (comum ao iOS e ao Android).
#
# Por que dinâmica: o libdivecomputer é LGPL-2.1, e a LGPL pede que quem recebe o app possa trocar a
# biblioteca por outra versão. Como framework separado dentro do app, ela pode ser recompilada daqui
# (mesma fonte, mesmo script) e substituída sem mexer no resto do app.
#
# Rodar de novo só quando a versão do libdivecomputer mudar:  ./build-libdivecomputer.sh
set -euo pipefail
cd "$(dirname "$0")"

NAME=LibDiveComputer
VERSION=0.9.0
MIN_IOS=16.4
OUT=build-xcframework
rm -rf "$OUT" "$NAME.xcframework"

SOURCES=$(ls ../libdivecomputer/src/*.c | grep -v serial_win32.c)
# o que o configure da biblioteca detectaria no iOS (ver configure.ac); sem as portas seriais do macOS (IOKit)
DEFINES="-DHAVE_PTHREAD_H=1 -DHAVE_UNISTD_H=1 -DHAVE_SYS_PARAM_H=1 -DHAVE_SYS_SOCKET_H=1 -DHAVE_MACH_MACH_TIME_H=1 \
-DHAVE_LOCALTIME_R=1 -DHAVE_GMTIME_R=1 -DHAVE_TIMEGM=1 -DHAVE_CLOCK_GETTIME=1 -DHAVE_MACH_ABSOLUTE_TIME=1"

build() { # $1 sdk, $2 alvo do clang, $3 pasta
  local sdk="$1" target="$2" dir="$OUT/$3/$NAME.framework"
  mkdir -p "$dir"
  xcrun --sdk "$sdk" clang -dynamiclib -O2 -w -fvisibility=default \
    -target "$target" -isysroot "$(xcrun --sdk "$sdk" --show-sdk-path)" \
    -I../libdivecomputer/include -I../libdivecomputer/src $DEFINES \
    -install_name "@rpath/$NAME.framework/$NAME" \
    -current_version "$VERSION" -compatibility_version 0.9.0 \
    $SOURCES -o "$dir/$NAME.$(echo "$target" | cut -d- -f1)"
}

plist() { # $1 pasta, $2 plataforma
  cat > "$OUT/$1/$NAME.framework/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>$NAME</string>
  <key>CFBundleIdentifier</key><string>app.scubabook.libdivecomputer</string>
  <key>CFBundleName</key><string>$NAME</string>
  <key>CFBundlePackageType</key><string>FMWK</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleSupportedPlatforms</key><array><string>$2</string></array>
  <key>MinimumOSVersion</key><string>$MIN_IOS</string>
</dict>
</plist>
EOF
}

# aparelho: arm64
build iphoneos "arm64-apple-ios$MIN_IOS" device
mv "$OUT/device/$NAME.framework/$NAME.arm64" "$OUT/device/$NAME.framework/$NAME"
plist device iPhoneOS

# simulador: arm64 + x86_64 num binário só
build iphonesimulator "arm64-apple-ios$MIN_IOS-simulator" simulator
build iphonesimulator "x86_64-apple-ios$MIN_IOS-simulator" simulator
xcrun lipo -create "$OUT/simulator/$NAME.framework/$NAME.arm64" "$OUT/simulator/$NAME.framework/$NAME.x86_64" \
  -output "$OUT/simulator/$NAME.framework/$NAME"
rm "$OUT/simulator/$NAME.framework/$NAME.arm64" "$OUT/simulator/$NAME.framework/$NAME.x86_64"
plist simulator iPhoneSimulator

xcodebuild -create-xcframework \
  -framework "$OUT/device/$NAME.framework" \
  -framework "$OUT/simulator/$NAME.framework" \
  -output "$NAME.xcframework" >/dev/null
rm -rf "$OUT"
echo "ok: $NAME.xcframework ($VERSION)"
