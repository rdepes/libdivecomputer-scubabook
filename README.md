# libdivecomputer for ScubaBook

[Português abaixo](#português)

The [ScubaBook](https://www.scubabook.app) app reads dive computers over Bluetooth with
[libdivecomputer](https://www.libdivecomputer.org) **v0.9.0**, licensed under the **GNU LGPL 2.1**
(see `LICENSE`). This repository exists so that anyone can rebuild that library and replace the copy that
ships inside the app, as the LGPL (section 6) requires.

- `libdivecomputer/` — the library's source, **unmodified**, from
  [tag v0.9.0](https://github.com/libdivecomputer/libdivecomputer/tree/v0.9.0)
  (commit `25b8fed709106dc693baad13eb47297abba46d98`). Only files that take no part in the build were left out
  (examples, docs, autotools); `include/libdivecomputer/version.h` was generated from `version.h.in`.
  See `libdivecomputer/ORIGEM.md`.
- `ios/build-libdivecomputer.sh` — builds `LibDiveComputer.xcframework`, the **dynamic framework** that the
  iPhone app loads at runtime. Needs Xcode. The `HAVE_*` defines are what the library's `configure` would detect on
  iOS.
- `android/` — the CMake project that builds `libdivecomputer.so`, the **shared library** inside the Android
  APK. Needs the Android NDK.

ScubaBook itself is not open source; its binary only calls the public `dc_*` API of this library.

## Replacing the library

**Android.** Build `libdivecomputer.so` with the NDK (`android/`), then replace `lib/<abi>/libdivecomputer.so`
inside the APK and re-sign it with your own key (for example with `apktool` + `apksigner`).

**iPhone.** Run `ios/build-libdivecomputer.sh`, then replace `Frameworks/LibDiveComputer.framework` inside the app
bundle and re-sign the app with your own certificate. Because the App Store delivers the app encrypted, you need
a copy of the app without that encryption to do this: write to **contato@scubabook.app** and we will send it at
no cost.

Changes to the library itself belong upstream: https://github.com/libdivecomputer/libdivecomputer

---

## Português

O app [ScubaBook](https://www.scubabook.app) lê computadores de mergulho por Bluetooth com o
[libdivecomputer](https://www.libdivecomputer.org) **v0.9.0**, licenciado sob a **GNU LGPL 2.1** (`LICENSE`).
Este repositório existe para que qualquer pessoa possa recompilar essa biblioteca e trocar a cópia que vai dentro
do app, como a LGPL (seção 6) pede.

- `libdivecomputer/` — a fonte da biblioteca, **sem modificação**, da tag v0.9.0 (ver `ORIGEM.md`).
- `ios/build-libdivecomputer.sh` — gera o `LibDiveComputer.xcframework`, o framework **dinâmico** que o app do
  iPhone carrega. Precisa do Xcode.
- `android/` — projeto CMake que gera a `libdivecomputer.so`, a biblioteca **compartilhada** dentro do APK.
  Precisa do NDK.

**Para trocar:** no Android, substitua `lib/<abi>/libdivecomputer.so` no APK e assine de novo com a sua chave; no
iPhone, substitua `Frameworks/LibDiveComputer.framework` no pacote do app e assine com o seu certificado. Como a
App Store entrega o app criptografado, você precisa de uma cópia sem essa criptografia: escreva para
**contato@scubabook.app** e enviamos sem custo.
