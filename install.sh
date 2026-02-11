#!/bin/bash

set -e

# GLM CLI Installation Script
# This script detects the OS and architecture, downloads the appropriate binary,
# and installs it to ~/.local/bin

REPO="okkyok/glm"
INSTALL_DIR="$HOME/.local/bin"
BINARY_NAME="glm"
ALLOW_UNVERIFIED="${GLM_ALLOW_UNVERIFIED:-0}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "darwin" ;;
        Linux*)  echo "linux" ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            log_error "This installer supports macOS and Linux only."
            exit 1
            ;;
    esac
}

# Detect architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64) echo "amd64" ;;
        arm64|aarch64) echo "arm64" ;;
        *)
            log_error "Unsupported architecture: $(uname -m)"
            log_error "This installer supports amd64 and arm64 only."
            exit 1
            ;;
    esac
}

# Get latest release version
get_latest_version() {
    curl --proto '=https' --tlsv1.2 -fsSL "https://api.github.com/repos/$REPO/releases/latest" | \
        grep '"tag_name":' | \
        sed -E 's/.*"([^"]+)".*/\1/' | \
        head -n1
}

# Check if binary exists in release
check_binary_exists() {
    local version=$1
    local os=$2
    local arch=$3
    local binary_name="glm-$os-$arch"
    local url="https://github.com/$REPO/releases/download/$version/$binary_name"

    # GitHub releases return 302 redirect, not 200 OK
    if curl --proto '=https' --tlsv1.2 -sS --head --location "$url" | head -n 1 | grep -qE "(200|302)"; then
        return 0
    else
        return 1
    fi
}

sha256_cmd() {
    if command -v shasum >/dev/null 2>&1; then
        echo "shasum -a 256"
    elif command -v sha256sum >/dev/null 2>&1; then
        echo "sha256sum"
    else
        return 1
    fi
}

verify_checksum() {
    local file=$1
    local version=$2
    local binary_name=$3
    local checksum_url="https://github.com/$REPO/releases/download/$version/checksums.txt"
    local checksum_file
    checksum_file=$(mktemp "/tmp/glm-checksums.XXXXXX")

    if ! curl --proto '=https' --tlsv1.2 -fsSL -o "$checksum_file" "$checksum_url"; then
        rm -f "$checksum_file"
        if [[ "$ALLOW_UNVERIFIED" == "1" ]]; then
            log_warning "checksums.txt not found for $version. Continuing because GLM_ALLOW_UNVERIFIED=1."
            return 0
        fi
        log_error "Checksum file is unavailable for $version."
        log_error "Set GLM_ALLOW_UNVERIFIED=1 only if you accept the security risk."
        exit 1
    fi

    local expected
    expected=$(awk -v f="$binary_name" '$2 == f {print $1}' "$checksum_file" | head -n1)
    rm -f "$checksum_file"
    if [[ -z "$expected" ]]; then
        if [[ "$ALLOW_UNVERIFIED" == "1" ]]; then
            log_warning "No checksum entry for $binary_name. Continuing because GLM_ALLOW_UNVERIFIED=1."
            return 0
        fi
        log_error "No checksum entry found for $binary_name in checksums.txt."
        exit 1
    fi

    local sha_cmd
    if ! sha_cmd=$(sha256_cmd); then
        log_error "No SHA-256 tool found (shasum/sha256sum)."
        exit 1
    fi

    local actual
    actual=$($sha_cmd "$file" | awk '{print $1}')
    if [[ "$actual" != "$expected" ]]; then
        log_error "Checksum verification failed for $binary_name."
        log_error "Expected: $expected"
        log_error "Actual:   $actual"
        exit 1
    fi

    log_success "Checksum verified for $binary_name"
}

# Download and install binary
install_binary() {
    local version=$1
    local os=$2
    local arch=$3
    local binary_name="glm-$os-$arch"
    local url="https://github.com/$REPO/releases/download/$version/$binary_name"
    local temp_file
    temp_file=$(mktemp "/tmp/${binary_name}.XXXXXX")

    log_info "Downloading GLM CLI $version for $os/$arch..."
    log_info "URL: $url"

    if ! curl --proto '=https' --tlsv1.2 -fL -o "$temp_file" "$url"; then
        log_error "Failed to download binary from $url"
        exit 1
    fi

    verify_checksum "$temp_file" "$version" "$binary_name"

    # Make binary executable
    chmod +x "$temp_file"

    # Create install directory if it doesn't exist
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
    fi

    # Move binary to install directory
    if ! mv "$temp_file" "$INSTALL_DIR/$BINARY_NAME"; then
        log_error "Failed to install binary to $INSTALL_DIR"
        exit 1
    fi

    log_success "GLM CLI installed to $INSTALL_DIR/$BINARY_NAME"
}

# Verify installation
verify_installation() {
    if command -v glm >/dev/null 2>&1; then
        local version=$(glm --version 2>/dev/null || echo "unknown")
        log_success "Installation verified! GLM CLI is ready to use."
        log_info "Run 'glm --help' to get started."

        # Check if ~/.local/bin is in PATH
        if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
            log_warning "$INSTALL_DIR is not in your PATH"
            log_info "To use GLM CLI from anywhere, add this line to your shell profile:"
            log_info "  ~/.bashrc (for bash) or ~/.zshrc (for zsh):"
            log_info ""
            log_info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
            log_info ""
            log_info "Then restart your terminal or run: source ~/.bashrc"
        fi
    else
        # Check if binary exists at install location even if not in PATH
        if [[ -f "$INSTALL_DIR/$BINARY_NAME" ]]; then
            log_success "GLM CLI installed successfully to $INSTALL_DIR/$BINARY_NAME"
            log_warning "However, $INSTALL_DIR is not in your PATH"
            log_info "To use GLM CLI, add this line to your shell profile:"
            log_info "  ~/.bashrc (for bash) or ~/.zshrc (for zsh):"
            log_info ""
            log_info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
            log_info ""
            log_info "Then restart your terminal or run: source ~/.bashrc"
            log_info "Or run directly with: $INSTALL_DIR/$BINARY_NAME"
        else
            log_error "Installation verification failed. GLM CLI not found."
            exit 1
        fi
    fi
}

# Main installation function
main() {
    echo "🚀 GLM CLI Installer"
    echo "===================="

    # Check dependencies
    if ! command -v curl >/dev/null 2>&1; then
        log_error "curl is required but not installed."
        exit 1
    fi
    if ! command -v awk >/dev/null 2>&1; then
        log_error "awk is required but not installed."
        exit 1
    fi

    # Detect system
    OS=$(detect_os)
    ARCH=$(detect_arch)
    log_info "Detected system: $OS/$ARCH"

    # Get latest version
    log_info "Fetching latest release version..."
    VERSION=$(get_latest_version)
    if [[ -z "$VERSION" ]]; then
        log_error "Failed to fetch latest release version"
        exit 1
    fi
    log_info "Latest version: $VERSION"

    # Check if binary exists for this platform
    if ! check_binary_exists "$VERSION" "$OS" "$ARCH"; then
        log_error "Binary not available for $OS/$ARCH in release $VERSION"
        log_error "Please check https://github.com/$REPO/releases for available binaries"
        exit 1
    fi

    # Check if already installed
    if command -v glm >/dev/null 2>&1; then
        log_warning "GLM CLI is already installed"
        echo -n "Do you want to reinstall/update? (y/N): "
        read -r response </dev/tty
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi

    # Install
    install_binary "$VERSION" "$OS" "$ARCH"
    verify_installation

    echo ""
    log_success "🎉 GLM CLI installation completed successfully!"
    echo ""
    echo "Quick start:"
    echo "  glm --help          # Show help"
    echo "  glm token set       # Set your API token"
    echo "  glm                 # Launch Claude with GLM (session-based)"
    echo "  glm install claude  # Install Claude Code"
    echo ""
}

# Run main function
main "$@"
