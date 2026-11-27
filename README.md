# RPG Fichas — app Flutter

Cliente desktop (Windows/Linux) e mobile (Android) do RPG Fichas. É um app
local-first: as fichas ficam em SQLite no dispositivo e os catálogos são os
JSONs autorais de [`json/`](json/), empacotados como assets somente leitura.

Este diretório é o projeto inteiro: código (`lib/`), catálogos (`json/`),
documentação (`docs/`), o app web legado (`web/`) e a configuração das
plataformas (`android/`, `linux/`, `windows/`). Na raiz do repositório ficam
apenas a infraestrutura de git (`.git/`, `.github/`, `.githooks/`,
`.gitignore`, `.gitmessage`).

## Estado atual

Implementação funcional da experiência desktop (réplica do app web):

- Dashboard "Minhas fichas" — criar, acessar, exportar (JSON) e excluir.
- Ficha completa com as 15 seções + barras de vida/sanidade, escudo de
  defesa, dados de atributo, trilha paranormal e sumário lateral flutuante.
- Catálogos carregados de `json/` com pickers (armas, proteções, rituais,
  poderes, habilidades e itens), com os mesmos filtros do web.
- Persistência em SQLite via Drift; autosave com debounce de 600 ms.

## Como rodar

```bash
flutter pub get
flutter run -d linux     # ou windows
flutter run -d <device>  # Android
```

Plataformas geradas: `android`, `linux` e `windows`. iOS/macOS ficam fora desta
entrega porque exigem toolchain Apple.

## Comandos

```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs  # codegen do Drift
dart format .
```

## Pré-requisitos de build

- **Linux:** `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`,
  `build-essential`.
- **Windows:** Visual Studio 2022 com o workload *Desktop development with C++*.
