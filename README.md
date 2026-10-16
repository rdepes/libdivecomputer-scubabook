# libdivecomputer for ScubaBook

[Português abaixo](#português)

The [ScubaBook](https://www.scubabook.app) app reads dive computers over Bluetooth with
[libdivecomputer](https://www.libdivecomputer.org) **v0.9.0**, licensed under the **GNU LGPL 2.1** (`LICENSE`).
ScubaBook uses the library **without modifications**, as a separate dynamic framework (iPhone) and shared
library (Android). ScubaBook itself is not open source; its binary only calls the public `dc_*` API.

This repository is part of what the LGPL 2.1 (section 6) asks for: the exact source of the library as shipped, the
scripts that build it, and the instructions to rebuild it, replace it inside the app and sign the result yourself.

## What is here

- `libdivecomputer/` — the library's source, **unmodified**, from
  [tag v0.9.0](https://github.com/libdivecomputer/libdivecomputer/tree/v0.9.0)
  (commit `25b8fed709106dc693baad13eb47297abba46d98`). Only files that take no part in the build were left out
  (examples, docs, autotools); `include/libdivecomputer/version.h` was generated from `version.h.in`.
  See `libdivecomputer/ORIGEM.md`.
- `ios/build-libdivecomputer.sh` — builds `LibDiveComputer.xcframework`, the **dynamic framework** the iPhone app
  loads at runtime (`@rpath/LibDiveComputer.framework/LibDiveComputer`, min iOS 16.4, arm64 device + arm64/x86_64
  simulator). Needs Xcode.
- `android/` — the CMake project (`CMakeLists.txt`, `build.sh`) that builds `libdivecomputer.so` for
  arm64-v8a, armeabi-v7a, x86_64 and x86 (android-24, 16 KB page sizes). Needs the Android NDK.

## Which tag matches your app version

Every ScubaBook build that ships the library gets a tag here pointing at the exact source and scripts used:

| App version | Platform | Tag | Toolchain |
|---|---|---|---|
| iPhone build 18 (1.0.0) | iOS | `scubabook-ios-18` | Xcode 26.x, iOS SDK 26 |
| iPhone build 19 (1.0.0) | iOS | `scubabook-ios-19` | Xcode 26.6, iOS SDK 26 |
| Android versionCode 12 (1.0.0) | Android | `scubabook-android-12` | NDK 27.1.12297006 |
| Android versionCode 13 (1.0.0) | Android | `scubabook-android-13` | NDK 27.1.12297006 |

(Settings → About in the app shows the build number; on iPhone it is also in Settings → General → iPhone Storage.)

## Written offer (LGPL 2.1, section 6(c))

For at least three years after the last distribution of each version of ScubaBook, upon request sent to
**contato@scubabook.app**, we provide at no charge the materials specified in section 6(a) of the LGPL 2.1 for that
version: the corresponding source of libdivecomputer (this repository, at the tag above) and the artifacts and
instructions necessary to link or relink ScubaBook with a modified, interface-compatible version of the library —
including a copy of the app package for that version without the store's encryption. Tell us the platform and the
build number.

## Rebuild, replace and sign

The library is loaded at runtime, so the app's executable is not rebuilt: you rebuild the library, swap the file
inside the app package and sign the package with credentials **you** are authorized to use. No ScubaBook or store
private key or distribution certificate is ever provided.

### iPhone

1. Check out the tag for your build, edit `libdivecomputer/` as you wish (keep the public `dc_*` interface), run
   `ios/build-libdivecomputer.sh` → `ios/LibDiveComputer.xcframework`.
2. Get the app package for your build from the written offer above (`ScubaBook-ios-<build>.ipa`, not encrypted).
   Unzip it: `Payload/ScubaBook.app`.
3. Replace `Payload/ScubaBook.app/Frameworks/LibDiveComputer.framework` with
   `LibDiveComputer.xcframework/ios-arm64/LibDiveComputer.framework`.
4. Sign with your own Apple development certificate and a provisioning profile that covers your device and the
   bundle id you choose (you may change the bundle id in `Info.plist` to one of your own):
   `codesign --force --deep --sign "<your identity>" --entitlements <your.entitlements> Payload/ScubaBook.app`
5. Zip `Payload/` back into an `.ipa` and install on your device with Xcode (Window → Devices) or
   `ios-deploy`. The app will run with your modified library.

### Android

1. Check out the tag for your build, edit `libdivecomputer/`, run `ANDROID_NDK=<path> android/build.sh` →
   `android/build/<abi>/libdivecomputer.so`.
2. Get the app package (`ScubaBook-android-v<versionCode>.aab`) from the written offer, or use a universal APK
   generated from it: `bundletool build-apks --mode=universal --bundle ScubaBook-android-v<n>.aab --output app.apks`
   then unzip `universal.apk`.
3. Replace `lib/<abi>/libdivecomputer.so` inside the APK (e.g. with `apktool d` / `apktool b`, or by editing the
   zip and re-aligning with `zipalign`).
4. Sign with your own key: `apksigner sign --ks <your.keystore> app.apk` (any modification after the original
   signature invalidates it; your signature replaces it).
5. Install with `adb install app.apk` (uninstall the store copy first: a different signing key cannot update it).

Changes to the library itself belong upstream: https://github.com/libdivecomputer/libdivecomputer

---

## Português

O app [ScubaBook](https://www.scubabook.app) lê computadores de mergulho por Bluetooth com o
[libdivecomputer](https://www.libdivecomputer.org) **v0.9.0**, licenciado sob a **GNU LGPL 2.1** (`LICENSE`). O
ScubaBook usa a biblioteca **sem modificação**, como framework dinâmico (iPhone) e biblioteca compartilhada
(Android), separados do app. O ScubaBook em si não é código aberto; o binário só chama a API pública `dc_*`.

Este repositório é parte do que a LGPL 2.1 (seção 6) pede: a fonte exata da biblioteca tal como embarcada, os
scripts que a compilam e as instruções para recompilar, trocar dentro do app e assinar o resultado você mesmo.

- `libdivecomputer/` — a fonte, sem modificação, da tag v0.9.0 (ver `ORIGEM.md`).
- `ios/build-libdivecomputer.sh` — gera o `LibDiveComputer.xcframework` (precisa do Xcode).
- `android/` — projeto CMake que gera a `libdivecomputer.so` (precisa do NDK).

**Tag por versão do app:** `scubabook-ios-18`, `scubabook-ios-19`, `scubabook-android-12`, `scubabook-android-13`
(tabela acima, com a versão das ferramentas).

**Oferta escrita (LGPL 2.1, § 6(c)).** Durante pelo menos três anos após a última distribuição de cada versão do
ScubaBook, mediante pedido para **contato@scubabook.app**, fornecemos sem custo os materiais do § 6(a) daquela
versão: a fonte correspondente da libdivecomputer (este repositório, na tag) e os artefatos e instruções
necessários para ligar ou religar o ScubaBook com uma versão modificada e compatível da biblioteca — inclusive uma
cópia do pacote do app daquela versão sem a criptografia da loja. Diga a plataforma e o número do build.

**Recompilar, trocar e assinar.** A biblioteca é carregada em tempo de execução: o executável do app não é
recompilado. Você recompila a biblioteca, troca o arquivo dentro do pacote e assina o pacote com credenciais
**suas** (certificado de desenvolvimento Apple e perfil do seu aparelho; chave própria no Android). Nenhuma chave
privada ou certificado do ScubaBook ou das lojas é fornecido. Os passos, comando a comando, estão na seção em
inglês acima (iPhone: `codesign` no `.app` com o framework trocado e instalação pelo Xcode; Android: `bundletool`,
troca do `.so`, `apksigner` com a sua chave, `adb install`).

Mudanças na biblioteca em si pertencem ao projeto original: https://github.com/libdivecomputer/libdivecomputer
