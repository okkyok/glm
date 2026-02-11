# GLM CLI

A command-line interface for launching Claude Code with GLM (ChatGLM) settings via BigModel API, using temporary session-based configuration.

## Features

- 🚀 **Session-Based Launch**: Launch Claude with GLM settings temporarily (no persistent config changes)
- 🎯 **Model Selection**: Choose different GLM models at launch time (glm-4.7, glm-4.6, glm-4.5, glm-4.5-air, etc.)
- 🔀 **Flag Passthrough**: Pass any claude CLI flags directly through glm (e.g., `--allowedTools`, `--verbose`)
- ⚡ **YOLO Mode**: Skip permission prompts with `--yolo` flag for faster workflows
- 📦 **Auto-Install**: Install Claude Code with built-in npm dependency checking
- 🔄 **Auto-Update**: Check for and install updates with interactive update command
- ⚙️ **Token Management**: Securely manage your authentication token

## Installation

### Quick Install (Fast, Less Secure)

`curl | bash` is convenient, but not the safest distribution path.

**Automatic installer:**
```bash
curl -fsSL https://raw.githubusercontent.com/xqsit94/glm/main/install.sh | bash
```

### Recommended Install (Manual + Checksum Verification)

```bash
# 1) Download binary and checksums from the release page
curl -fL -o glm-darwin-arm64 "https://github.com/xqsit94/glm/releases/download/v1.2.0/glm-darwin-arm64"
curl -fL -o checksums.txt "https://github.com/xqsit94/glm/releases/download/v1.2.0/checksums.txt"

# 2) Verify checksum (macOS)
grep " glm-darwin-arm64$" checksums.txt | shasum -a 256 -c

# 3) Install
chmod +x glm-darwin-arm64
mv glm-darwin-arm64 ~/.local/bin/glm
```

**Alternative - Manual Quick Install:**
```bash
# Create user bin directory and download GLM CLI
mkdir -p ~/.local/bin
curl -L -o ~/.local/bin/glm "https://github.com/xqsit94/glm/releases/download/v1.2.0/glm-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/amd64/')"
chmod +x ~/.local/bin/glm

# Add to PATH (one-time setup)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Both methods will:
- Detect your operating system and architecture
- Download the latest binary release
- Install to your user directory
- Set up PATH for easy access

### Manual Installation

#### Option 1: Download Pre-built Binary

1. Go to the [releases page](https://github.com/xqsit94/glm/releases)
2. Download the binary for your platform:
   - macOS Intel: `glm-darwin-amd64`
   - macOS Apple Silicon: `glm-darwin-arm64`
   - Linux x64: `glm-linux-amd64`
   - Linux ARM64: `glm-linux-arm64`
3. Make it executable and move to PATH:
   ```bash
   chmod +x glm-*
   sudo mv glm-* /usr/local/bin/glm
   ```

#### Option 2: Build from Source

**Prerequisites:**
- Go 1.24 or later
- Your GLM API token

```bash
git clone https://github.com/xqsit94/glm.git
cd glm
go mod tidy
go build -o glm
sudo mv glm /usr/local/bin/
```

## Authentication Setup

The GLM CLI supports multiple ways to provide your Anthropic API token:

### Option 1: Environment Variable (Recommended)
Prefer environment variables so tokens are not persisted to disk:
```bash
export ANTHROPIC_AUTH_TOKEN="your_token_here"
glm
```

`GLM_TOKEN` is also supported as a fallback variable.

### Option 2: Interactive Setup (TTY only)
On first run, the CLI can prompt you to set up your token:
```bash
glm  # Will prompt for token if not found
```

### Option 3: Manual Token Setup
```bash
glm token set  # Enter your token securely
```

### Non-interactive environments (CI/script)
For CI and scripts, disable prompts and use env vars:
```bash
export GLM_NON_INTERACTIVE=1
export ANTHROPIC_AUTH_TOKEN="your_token_here"
glm --non-interactive
```

**Token Priority Order:**
1. Environment variable `ANTHROPIC_AUTH_TOKEN`
2. Environment variable `GLM_TOKEN`
3. Config file `~/.glm/config.json`
4. Interactive prompt (TTY only, disabled by `GLM_NON_INTERACTIVE=1` or `--non-interactive`)

## Usage

### Launch Claude with GLM (Primary Usage)

Launch Claude with the default model (glm-4.7):
```bash
glm
```

Launch Claude with a specific model:
```bash
glm --model glm-4.5-air
glm -m glm-4.5-air
```

Launch Claude in YOLO mode (skip permission prompts):
```bash
glm --yolo
glm --yolo --model glm-4.5-air
```

Disable prompts explicitly (for scripts/automation):
```bash
glm --non-interactive
```

Pass additional flags directly to claude:
```bash
glm --allowedTools "Bash,Read,Write"
glm --verbose
glm --yolo --allowedTools "Bash,Read"
```

**How it works:**
- Sets temporary environment variables for the Claude session
- No persistent changes to Claude's configuration files
- Settings only apply to the launched Claude session
- To use Claude without GLM, just run `claude` directly

### Install Claude Code

Install Claude Code via npm (with automatic Node.js detection):
```bash
glm install claude
```

### Manage Authentication Token

Set your API token:
```bash
glm token set
```

View current token (masked):
```bash
glm token show
```

Clear stored token:
```bash
glm token clear
```

### Update GLM

Check for updates:
```bash
glm update --check
```

Update to latest version:
```bash
glm update
```

Update without confirmation:
```bash
glm update --force
```

`glm update` verifies SHA-256 checksums from release `checksums.txt` before install.
If a release does not publish checksums, update will fail by default.
You can bypass this only if you accept the risk:
```bash
GLM_ALLOW_UNVERIFIED=1 glm update
```

### Help

Get help for any command:
```bash
glm --help
glm install --help
glm token --help
glm update --help
```

## Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `glm` | Launch Claude with GLM (temporary config) | `glm --model glm-4.7` |
| `glm --yolo` | Launch with permission prompts skipped | `glm --yolo` |
| `glm --<flag>` | Pass any flag through to claude | `glm --allowedTools "Bash"` |
| `glm install claude` | Install Claude Code | `glm install claude` |
| `glm token set` | Set authentication token | `glm token set` |
| `glm token show` | Show current token (masked) | `glm token show` |
| `glm token clear` | Clear stored token | `glm token clear` |
| `glm update` | Update GLM to latest version | `glm update` |
| `glm update --check` | Check for updates only | `glm update --check` |

### Deprecated Commands

These commands are deprecated and now no-op. Use `glm` with `--model` flag instead:

| Command | Status | Replacement |
|---------|--------|-------------|
| `glm enable` | ⚠️ Deprecated (no-op) | Use `glm` instead |
| `glm disable` | ⚠️ Deprecated (no-op) | Run `claude` directly |
| `glm set` | ❌ Removed | Use `glm --model X` |

## Available Models

- `glm-4.7` (default)
- `glm-4.6`
- `glm-4.5`
- `glm-4.5-air`
- Any other GLM model supported by BigModel API

## Configuration Files

The CLI manages the following files:
- `~/.glm/config.json` - Your authentication token and preferences

`~/.glm/config.json` is written with restrictive permissions (`0600`).
For higher security, prefer environment variables so no token is persisted.

**Note:** GLM does not modify `~/.claude/settings.json`. All configuration is passed via temporary environment variables.

## How It Works

1. **Launch (`glm`)**: Launches Claude Code with temporary environment variables:
   - `ANTHROPIC_BASE_URL=https://open.bigmodel.cn/api/anthropic`
   - `ANTHROPIC_AUTH_TOKEN=<your_token>`
   - `ANTHROPIC_MODEL=<selected_model>`

2. **Session-Based**: Settings only exist for the launched Claude session. No persistent file modifications.

3. **Token Storage**: Token can be stored in `~/.glm/config.json` (permission `0600`) for convenience, but env vars are recommended for stronger security.

4. **Install**: Checks for npm and installs Claude Code globally.

5. **Update**: Downloads and replaces the GLM binary with the latest version from GitHub.

## Example Workflow

```bash
# Install GLM CLI
curl -fsSL https://raw.githubusercontent.com/xqsit94/glm/main/install.sh | bash

# First time setup
glm install claude        # Install Claude Code
glm token set            # Enter your token securely

# Launch Claude with GLM (default model: glm-4.7)
glm

# Launch with specific model
glm --model glm-4.5-air

# Launch in YOLO mode (skip permission prompts)
glm --yolo

# Pass additional flags to claude
glm --allowedTools "Bash,Read,Write"

# Use Claude without GLM
claude

# Check for updates
glm update --check

# Update to latest version
glm update
```

## Troubleshooting

### Installation Issues

#### curl not found
If you get a "curl not found" error:
- **macOS**: Install Xcode Command Line Tools: `xcode-select --install`
- **Linux**: Install curl: `sudo apt install curl` (Ubuntu/Debian) or `sudo yum install curl` (CentOS/RHEL)

#### Permission denied during installation
If the installer fails with permission errors:
```bash
# Download and run manually with explicit sudo
curl -fsSL https://raw.githubusercontent.com/xqsit94/glm/main/install.sh -o install.sh
chmod +x install.sh
sudo ./install.sh
```

#### Binary not found for your platform
If no binary is available for your platform:
1. Check the [releases page](https://github.com/xqsit94/glm/releases) for available binaries
2. Build from source using the manual installation instructions

### Runtime Issues

#### npm not found
If you get an npm error when running `glm install claude`:
1. Install Node.js from https://nodejs.org/
2. Restart your terminal
3. Run `glm install claude` again

#### Authentication token not found
Set up your token using any of these methods:
- Set environment variable (recommended): `export ANTHROPIC_AUTH_TOKEN="your_token"`
- Or set fallback variable: `export GLM_TOKEN="your_token"`
- `glm token set` (TTY only)

In CI/non-interactive shells, prompts are disabled:
```bash
export GLM_NON_INTERACTIVE=1
export ANTHROPIC_AUTH_TOKEN="your_token"
glm --non-interactive
```

#### Claude still using default settings
The session-based configuration means:
- Settings only apply to Claude sessions launched via `glm`
- If you run `claude` directly, it uses default settings
- This is intentional - use `glm` to launch with GLM settings

#### Command not found after installation
If `glm` command is not found after installation:
1. Check if `/usr/local/bin` or `~/.local/bin` is in your PATH: `echo $PATH`
2. Add to PATH if missing (add to `.bashrc`, `.zshrc`, etc.):
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```
3. Restart your terminal or run: `source ~/.bashrc` (or `.zshrc`)

#### Update fails with permission error
If `glm update` fails with permission denied:
```bash
sudo glm update
```

## Migration from Previous Versions

If you're upgrading from version 1.0.x:

### ⚠️ IMPORTANT: Check Old Configuration File

Version 1.0.x may have created a persistent `~/.claude/settings.json`.
Session-based versions do not use this file. If it still contains GLM overrides, `claude` may keep using GLM unexpectedly.

```bash
cat ~/.claude/settings.json
```

If this file still hard-codes GLM env values and you no longer want that behavior, remove it manually.

### Other Changes:

1. **Deprecated commands**: `glm enable` and `glm disable` are now no-op with warnings
2. **Removed command**: `glm set` has been removed - use `glm --model X` instead
3. **New usage**: Just run `glm` to launch Claude with GLM, or `glm --model X` to specify a model

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Support

For issues and feature requests, please create an issue in the repository.
