# mise-codelldb

Mise plugin to install the CodeLLDB debug adapter (vadimcn/codelldb) across platforms.

## Install

- Link locally for development:
```
mise plugin link --force codelldb .
```

- Install a specific version (use Git tags like `v1.11.5`):
```
mise install codelldb@v1.11.5
```

This downloads the appropriate VSIX for your platform and exposes the adapter at `$(mise where codelldb)/bin/codelldb` (Windows: `codelldb.exe`).

## How it works

- Versions come from GitHub tags on `vadimcn/codelldb`.
- The plugin selects the correct VSIX based on OS/arch, downloads it, and extracts the adapter binary.
- Supported assets:
  - Linux: `codelldb-x86_64-linux.vsix`, `codelldb-aarch64-linux.vsix`, `codelldb-arm-linux.vsix`
  - macOS: `codelldb-x86_64-darwin.vsix`, `codelldb-aarch64-darwin.vsix`
  - Windows: `codelldb-x86_64-windows.vsix`

## Development

- Lint/format: `mise run lint`
- Tests: `mise run test`
- CI locally: `mise run ci`

Debug with verbose logs: `MISE_DEBUG=1 mise install codelldb@latest`

## License

MIT
