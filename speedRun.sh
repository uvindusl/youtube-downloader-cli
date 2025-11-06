#!/usr/bin/env bash

set -e

# ASCII Art Banner
cat << "EOF"
██╗   ██╗ ██████╗ ██╗   ██╗████████╗██╗   ██╗██████╗     ██╗███╗   ██╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ 
╚██╗ ██╔╝██╔═══██╗██║   ██║╚══██╔══╝██║   ██║██╔══██╗    ██║████╗  ██║╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
 ╚████╔╝ ██║   ██║██║   ██║   ██║   ██║   ██║██████╔╝    ██║██╔██╗ ██║   ██║   ███████║██║     ██║     █████╗  ██████╔╝
  ╚██╔╝  ██║   ██║██║   ██║   ██║   ██║   ██║██╔══██╗    ██║██║╚██╗██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
   ██║   ╚██████╔╝╚██████╔╝   ██║   ╚██████╔╝██████╔╝    ██║██║ ╚████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
   ╚═╝    ╚═════╝  ╚═════╝    ╚═╝    ╚═════╝ ╚═════╝     ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
EOF

echo ""
echo "YouTube Downloader Installer"
echo "============================"
echo ""

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    OS="windows"
fi

echo "Detected OS: $OS"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo "Error: Python is not installed!"
    echo ""
    case $OS in
        linux)
            echo "Install Python with: sudo apt install python3 python3-pip python3-venv"
            ;;
        macos)
            echo "Install Python with: brew install python3"
            echo "Or download from: https://www.python.org/downloads/"
            ;;
        windows)
            echo "Download Python from: https://www.python.org/downloads/"
            echo "Make sure to check 'Add Python to PATH' during installation"
            ;;
    esac
    exit 1
fi

# Determine Python command
PYTHON_CMD="python3"
if ! command -v python3 &> /dev/null; then
    PYTHON_CMD="python"
fi

echo "Using Python: $PYTHON_CMD"
$PYTHON_CMD --version
echo ""

# Check if pip is available
if ! $PYTHON_CMD -m pip --version &> /dev/null; then
    echo "Error: pip is not installed!"
    echo "Install pip and try again"
    exit 1
fi

# Check if pipx is installed, install if not
if ! command -v pipx &> /dev/null; then
    echo "Installing pipx..."
    case $OS in
        linux)
            if command -v apt &> /dev/null; then
                sudo apt update
                sudo apt install -y pipx
            else
                $PYTHON_CMD -m pip install --user pipx
            fi
            ;;
        macos)
            if command -v brew &> /dev/null; then
                brew install pipx
            else
                $PYTHON_CMD -m pip install --user pipx
            fi
            ;;
        windows)
            $PYTHON_CMD -m pip install --user pipx
            ;;
    esac
    
    # Ensure pipx path
    $PYTHON_CMD -m pipx ensurepath
    
    echo "pipx installed"
    echo ""
fi

# Clone repository
echo "Downloading YouTube Downloader..."
TEMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'ytdownloader')
git clone https://github.com/uvindusl/youtube-downloader-cli.git "$TEMP_DIR" 2>/dev/null || {
    echo "Error: git is not installed or repository not accessible"
    echo ""
    case $OS in
        linux)
            echo "Install git with: sudo apt install git"
            ;;
        macos)
            echo "Install git with: brew install git"
            ;;
        windows)
            echo "Install git from: https://git-scm.com/download/win"
            ;;
    esac
    exit 1
}

echo "Downloaded successfully"
echo ""

# Install with pipx
echo "Installing YouTube Downloader..."
pipx install "$TEMP_DIR" --force

# Cleanup
rm -rf "$TEMP_DIR"

echo "Installation complete!"
echo ""

# OS-specific PATH instructions
case $OS in
    linux)
        # Add to both bash and zsh configs for compatibility
        CONFIGS=()
        
        [ -f "$HOME/.bashrc" ] && CONFIGS+=("$HOME/.bashrc")
        [ -f "$HOME/.zshrc" ] && CONFIGS+=("$HOME/.zshrc")
        
        # If neither exists, create based on default shell
        if [ ${#CONFIGS[@]} -eq 0 ]; then
            USER_SHELL=$(basename "$SHELL")
            if [[ "$USER_SHELL" == "zsh" ]]; then
                touch "$HOME/.zshrc"
                CONFIGS+=("$HOME/.zshrc")
            else
                touch "$HOME/.bashrc"
                CONFIGS+=("$HOME/.bashrc")
            fi
        fi
        
        echo "Detected shell: $(basename "$SHELL")"
        echo "Configuring PATH in: ${CONFIGS[*]}"
        echo ""
        
        # Add PATH to all config files
        for SHELL_RC in "${CONFIGS[@]}"; do
            if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC" 2>/dev/null; then
                echo "" >> "$SHELL_RC"
                echo "# Added by YouTube Downloader installer" >> "$SHELL_RC"
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
                echo "Added ~/.local/bin to PATH in $SHELL_RC"
            else
                echo "PATH already configured in $SHELL_RC"
            fi
        done
        
        # Also update current session
        export PATH="$HOME/.local/bin:$PATH"
        
        echo ""
        echo "   Restart your terminal OR run:"
        echo "   source ~/.zshrc    (for zsh)"
        echo "   source ~/.bashrc   (for bash)"
        ;;
    macos)
        # Add to both bash and zsh configs for compatibility
        CONFIGS=()
        
        [ -f "$HOME/.zshrc" ] && CONFIGS+=("$HOME/.zshrc")
        [ -f "$HOME/.bash_profile" ] && CONFIGS+=("$HOME/.bash_profile")
        [ -f "$HOME/.bashrc" ] && CONFIGS+=("$HOME/.bashrc")
        
        # If none exist, create based on default shell (macOS uses zsh by default)
        if [ ${#CONFIGS[@]} -eq 0 ]; then
            USER_SHELL=$(basename "$SHELL")
            if [[ "$USER_SHELL" == "zsh" ]]; then
                touch "$HOME/.zshrc"
                CONFIGS+=("$HOME/.zshrc")
            else
                touch "$HOME/.bash_profile"
                CONFIGS+=("$HOME/.bash_profile")
            fi
        fi
        
        echo "Detected shell: $(basename "$SHELL")"
        echo "Configuring PATH in: ${CONFIGS[*]}"
        echo ""
        
        # Add PATH to all config files
        for SHELL_RC in "${CONFIGS[@]}"; do
            if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC" 2>/dev/null; then
                echo "" >> "$SHELL_RC"
                echo "# Added by YouTube Downloader installer" >> "$SHELL_RC"
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
                echo " Added ~/.local/bin to PATH in $SHELL_RC"
            else
                echo "  PATH already configured in $SHELL_RC"
            fi
        done
        
        # Also update current session
        export PATH="$HOME/.local/bin:$PATH"
        
        echo ""
        echo "   Restart your terminal OR run:"
        echo "   source ~/.zshrc         (for zsh)"
        echo "   source ~/.bash_profile  (for bash)"
        ;;
    windows)
        echo "  You may need to restart your terminal or add to PATH manually"
        echo "PATH location: %USERPROFILE%\\.local\\bin"
        ;;
esac

echo ""
echo " Installation successful!"
echo ""
echo "Usage:"
echo "  youtube-download --url <VIDEO_URL> --type mp3"
echo "  youtube-download --url <VIDEO_URL> --type mp4"
echo ""
echo "Example:"
echo "  youtube-download --url https://youtube.com/watch?v=xxx --type mp3"
echo ""
