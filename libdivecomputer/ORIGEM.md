# libdivecomputer (cópia de fonte)

- Origem: https://github.com/libdivecomputer/libdivecomputer, tag **v0.9.0**, commit
  `25b8fed709106dc693baad13eb47297abba46d98` (30/06/2025).
- Licença: **LGPL-2.1** (arquivo `COPYING`). Sem taxa de licença.
- Sem modificação no código. Removidos só os arquivos que não entram no build (exemplos, documentação,
  autotools); `include/libdivecomputer/version.h` foi gerado a partir do `version.h.in` com a versão 0.9.0.
- Usada pelo módulo `DiveComputer` (leitura por Bluetooth, docs/importacao-direta.md, seção 2).
- Entra no app como **framework dinâmico separado** (`../ios/LibDiveComputer.xcframework`), gerado por
  `../ios/build-libdivecomputer.sh` a partir desta fonte. Para trocar a biblioteca por outra versão (direito da LGPL):
  substituir esta pasta, rodar o script e recompilar o app, ou trocar `LibDiveComputer.framework` dentro do app.
