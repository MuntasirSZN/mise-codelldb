# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Project Overview

A Mise plugin that installs the CodeLLDB debug adapter (vadimcn/codelldb) across platforms. The plugin downloads platform-specific VSIX files from GitHub releases, extracts them, and exposes the `codelldb` binary.

## Development Commands

- **Lint**: `mise run lint` - Runs `hk check` which executes luacheck, stylua, and actionlint
- **Format**: `mise run format` - Formats Lua scripts with stylua
- **Test**: `mise run test` - Run tests (note: no test task currently defined in mise.toml)
- **CI**: `mise run ci` - Runs both lint and test tasks
- **Debug installs**: `MISE_DEBUG=1 mise install codelldb@latest`

## Architecture

### Hook System
The plugin implements Mise's hook system with 4 Lua hooks in `hooks/`:

- **available.lua**: Fetches available versions from GitHub API (vadimcn/codelldb tags)
  - Implements caching with 12-hour TTL (cache_ttl = 12 * 60 * 60)
  - Falls back to ungh.cc `/repos/{owner}/{repo}/releases` API if GitHub API fails
    - ungh.cc returns `{releases: [{tag, name, ...}]}` format, converted to GitHub tags format
  - Supports GITHUB_TOKEN/GITHUB_API_TOKEN for rate limits
  - Marks pre-release versions (those with `-` in tag name)

- **pre_install.lua**: Determines the correct VSIX file for the platform
  - Maps OS/arch combinations to VSIX filenames (e.g., linux/x86_64 → codelldb-linux-x64.vsix)
  - Tries multiple candidate filenames per platform for compatibility
  - Probes GitHub releases to find which VSIX exists for the version
  - Returns download URL for the chosen VSIX

- **post_install.lua**: Extracts VSIX and sets up the binary
  - Extracts VSIX (zip format) using `unzip` (Unix) or `Expand-Archive` (Windows)
  - Creates wrapper script at `bin/codelldb` that executes `extension/adapter/codelldb`
  - Creates symlink from `lldb/` to `extension/lldb/` for LLDB library discovery (Unix only)
  - Runs sanity check with `--help` flag on Unix

- **env_keys.lua**: Sets up environment variables
  - Adds `bin/` to PATH
  - Sets DYLD_LIBRARY_PATH (macOS) or LD_LIBRARY_PATH (Linux) to `lldb/lib`

### Platform Detection
Platform-specific VSIX selection logic in pre_install.lua:
- Linux: x64, arm64, armhf variants
- Darwin: x64, arm64 variants
- Windows: x64 only (uses .cmd wrapper instead of shell script)

### Caching Strategy
Version list is cached in memory for 12 hours to reduce API calls. Cache stored in `cache` table with `versions` and `timestamp` fields.

## Testing Locally
Link the plugin for development: `mise plugin link --force codelldb .`

## Linting Configuration
`hk.pkl` defines three lint steps:
- luacheck: Lua static analysis
- stylua: Lua formatting
- actionlint: GitHub Actions workflow validation
