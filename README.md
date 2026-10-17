# libdivecomputer for ScubaBook

[Português abaixo](#português)

The [ScubaBook](https://www.scubabook.app) app reads dive computers over Bluetooth with
[libdivecomputer](https://www.libdivecomputer.org) **v0.9.0**, licensed under the **GNU LGPL 2.1** (`LICENSE`).
ScubaBook uses the library **without modifications**, as a separate dynamic framework (iPhone) and shared
library (Android). ScubaBook itself is not open source; its binary only calls the public `dc_*` API.

The library ships as a **separate dynamic component** that the app loads at runtime. The compliance approach for
the application's dynamic linking with libdivecomputer is based on **section 6(b)** of the GNU LGPL 2.1 (see "LGPL
compliance" below). This repository holds the exact source of the library as shipped, the scripts that build it, and
the instructions to rebuild it, replace it inside the app and sign the result yourself.

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
  arm64-v8a, armeabi-v7a, x86_64 and x86 (android-24, 16 KB page sizes). Needs the Android NDK and `cmake`
  (the one in `<sdk>/cmake/<version>/bin` is picked up automatically; or `brew install cmake`).

## Which tag matches your app version

Every ScubaBook build that ships the library gets a tag here pointing at the exact source and scripts used:

| App version | Platform | Tag | Toolchain |
|---|---|---|---|
| iPhone build 18 (1.0.0) | iOS | `scubabook-ios-18` | Xcode 26.x, iOS SDK 26 |
| iPhone build 19 (1.0.0) | iOS | `scubabook-ios-19` | Xcode 26.6, iOS SDK 26 |
| Android versionCode 12 (1.0.0) | Android | `scubabook-android-12` | NDK 27.1.12297006 |
| Android versionCode 13 (1.0.0) | Android | `scubabook-android-13` | NDK 27.1.12297006 |

(The app's Profile → Open-source licenses screen shows its version and build number and links to the matching tag.)

## LGPL compliance — dynamic library replacement

ScubaBook uses libdivecomputer as a separately distributed dynamic library.

The compliance approach for the application's dynamic linking with libdivecomputer is based on Section 6(b) of the
GNU LGPL v2.1.

This repository provides the corresponding libdivecomputer source code, applicable build scripts, version-specific
documentation, and instructions for building and replacing the library with a modified, interface-compatible version.

The application is proprietary. The source code of the ScubaBook application is not distributed under the LGPL merely
because the application uses libdivecomputer.

The applicable rights granted under the LGPL v2.1 remain fully preserved, including modification of the application
for the recipient's own use and reverse engineering for debugging such modifications, as required by Section 6.

The relevant files and instructions are identified by the application platform, version, and build number.

ScubaBook does not undertake to provide general technical support, maintenance, feature development, or updates for
user-modified versions of the application.

This support policy does not limit any rights granted by the LGPL v2.1 or any applicable legal obligations concerning
the distribution of libdivecomputer.

**App package for the procedure.** The store copy of the iPhone app is encrypted by Apple, so the replacement
procedure below starts from the app package as built (`ScubaBook-ios-<build>.ipa`, not encrypted; on Android the
`.aab` and a universal APK). ScubaBook keeps that package for each build in a private Relink Kit, together with the
hashes and test records, and makes it available on request to **contato@scubabook.app** (tell us the platform and
build number). No private signing keys or production credentials are ever provided.

## Rebuild, replace and sign

The library is loaded at runtime, so the app's executable is not rebuilt: you rebuild the library, swap the file
inside the app package and sign the package with credentials **you** are authorized to use. No ScubaBook or store
private key or distribution certificate is ever provided.

### iPhone

1. Check out the tag for your build, edit `libdivecomputer/` as you wish (keep the public `dc_*` interface), run
   `ios/build-libdivecomputer.sh` → `ios/LibDiveComputer.xcframework`.
2. Get the app package for your build from the Relink Kit (see "App package for the procedure" above:
   `ScubaBook-ios-<build>.ipa`, not encrypted).
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
2. Get the app package from the Relink Kit: the universal APK (`ScubaBook-android-v<versionCode>-universal.apk`,
   **unsigned**: you sign it in step 4) or the `.aab`, from which `bundletool build-apks --mode=universal --bundle
   ScubaBook-android-v<n>.aab --output app.apks` produces `universal.apk`.
3. Replace `lib/<abi>/libdivecomputer.so` inside the APK: `zip -d app.apk lib/<abi>/libdivecomputer.so` then
   `zip -0 -u app.apk lib/<abi>/libdivecomputer.so` — **`-0` (stored, no compression) is required**, the app uses
   `extractNativeLibs=false` and the installer rejects a compressed library; then `zipalign -p -f 4 app.apk aligned.apk`
   (16 KB pages) **before** signing.
4. Sign with your own key: `apksigner sign --ks <your.keystore> app.apk` (any modification after the original
   signature invalidates it; your signature replaces it).
5. Install with `adb install app.apk`. A different signing key cannot update the store copy: uninstall it first
   (local data such as unsynced drafts is lost; dives already saved are on your account) or use another user
   profile on the device.

Changes to the library itself belong upstream: https://github.com/libdivecomputer/libdivecomputer

---

## Português

O app [ScubaBook](https://www.scubabook.app) lê computadores de mergulho por Bluetooth com o
[libdivecomputer](https://www.libdivecomputer.org) **v0.9.0**, licenciado sob a **GNU LGPL 2.1** (`LICENSE`). O
ScubaBook usa a biblioteca **sem modificação**, como framework dinâmico (iPhone) e biblioteca compartilhada
(Android), separados do app. O ScubaBook em si não é código aberto; o binário só chama a API pública `dc_*`.

A biblioteca vai como **componente dinâmico separado**, carregado pelo app em tempo de execução. A estratégia de
conformidade relativa à vinculação dinâmica do aplicativo com a libdivecomputer baseia-se no **§ 6(b)** da GNU
LGPL 2.1 (ver "Conformidade LGPL" abaixo). Este repositório guarda a fonte exata da biblioteca tal como embarcada,
os scripts que a compilam e as instruções para recompilar, trocar dentro do app e assinar o resultado você mesmo.

- `libdivecomputer/` — a fonte, sem modificação, da tag v0.9.0 (ver `ORIGEM.md`).
- `ios/build-libdivecomputer.sh` — gera o `LibDiveComputer.xcframework` (precisa do Xcode).
- `android/` — projeto CMake que gera a `libdivecomputer.so` (precisa do NDK).

**Tag por versão do app:** `scubabook-ios-18`, `scubabook-ios-19`, `scubabook-android-12`, `scubabook-android-13`
(tabela acima, com a versão das ferramentas).

**Conformidade LGPL — substituição da biblioteca dinâmica.** O ScubaBook utiliza a libdivecomputer como biblioteca
dinâmica separada. A estratégia de conformidade relativa à vinculação dinâmica do aplicativo com a libdivecomputer
baseia-se no § 6(b) da GNU LGPL 2.1. Este repositório disponibiliza o código-fonte correspondente da libdivecomputer,
os scripts de compilação aplicáveis, a documentação específica de cada versão e as instruções para compilar e
substituir a biblioteca por uma versão modificada e compatível. O ScubaBook é um aplicativo proprietário. A utilização
da libdivecomputer não implica, por si só, o licenciamento do código-fonte do aplicativo sob a LGPL. Permanecem
preservados os direitos aplicáveis previstos na LGPL 2.1, incluindo a modificação do aplicativo para uso próprio e a
engenharia reversa para depuração dessas modificações, conforme exigido pelo § 6. Os arquivos e instruções
correspondentes são identificados pela plataforma, versão e número do build do aplicativo. O ScubaBook não assume
obrigação de prestar suporte técnico geral, manutenção, desenvolvimento de funcionalidades ou atualizações para
versões do aplicativo modificadas por usuários. Esta política de suporte não restringe os direitos concedidos pela
LGPL 2.1 nem quaisquer obrigações legais aplicáveis à distribuição da libdivecomputer.

**Pacote do app para o procedimento.** A cópia da App Store vem criptografada pela Apple; o procedimento parte do
pacote tal como gerado (`.ipa` sem criptografia; no Android o `.aab` e um APK universal). O ScubaBook guarda esse
pacote de cada build num Relink Kit privado, com hashes e registros de teste, e o disponibiliza mediante pedido a
**contato@scubabook.app** (diga a plataforma e o número do build). Nenhuma chave privada ou credencial de produção é
fornecida.

**Recompilar, trocar e assinar.** A biblioteca é carregada em tempo de execução: o executável do app não é
recompilado. Você recompila a biblioteca, troca o arquivo dentro do pacote e assina o pacote com credenciais
**suas** (certificado de desenvolvimento Apple e perfil do seu aparelho; chave própria no Android). Nenhuma chave
privada ou certificado do ScubaBook ou das lojas é fornecido. Os passos, comando a comando, estão na seção em
inglês acima (iPhone: `codesign` no `.app` com o framework trocado e instalação pelo Xcode; Android: `bundletool`,
troca do `.so`, `apksigner` com a sua chave, `adb install`).

Mudanças na biblioteca em si pertencem ao projeto original: https://github.com/libdivecomputer/libdivecomputer
