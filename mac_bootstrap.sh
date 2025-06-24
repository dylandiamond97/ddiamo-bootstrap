#!/bin/bash
set -euo pipefail

echo "===>>>  WE ARE STRAPPING BOOOOOOTS  <<<==="
echo -e "\n"

# Install Xcode CLI tools if not installed
if ! xcode-select -p &>/dev/null; then
	echo "Installing Xcode CLI tools..."
	xcode-select --install
fi

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Updating Homebrew..."
brew update
brew analytics off

# Install CLI tools if missing
cli_tools=(
	python
	pyenv
	terraform
	tflint
	git
	awscli
	awsume
	jq
	direnv
	wget
	mas
	pipx
)

for tool in "${cli_tools[@]}"; do
	if ! brew list "$tool" &>/dev/null; then
		echo "Installing $tool..."
		brew install "$tool"
	else
		echo "$tool is already installed."
	fi
done

# Ensure pipx paths are set
if pipx ensurepath 2>&1 | grep -q "already in PATH"; then
	echo "pipx binary path already in PATH."
else
	echo "Appended pipx binary path to shell config."
fi

# Install shell enhancements if missing
shell_enhancements=(
	zsh-autosuggestions
	zsh-syntax-highlighting
	fzf
	bat
)

for ext in "${shell_enhancements[@]}"; do
	if ! brew list "$ext" &>/dev/null; then
		echo "Installing $ext..."
		brew install "$ext"
	else
		echo "$ext is already installed."
	fi
done

# Python setup via pyenv
PYTHON_VERSION="3.12.3"
if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
	echo "Installing Python $PYTHON_VERSION via pyenv..."
	pyenv install "$PYTHON_VERSION"
else
	echo "Python $PYTHON_VERSION is already installed."
fi

echo "Setting global Python version to $PYTHON_VERSION..."
pyenv global "$PYTHON_VERSION"

echo "Upgrading pip..."
python3 -m pip install --upgrade pip

# Install PyCharm if not installed manually or by brew
if [ ! -d "/Applications/Pycharm.app" ] && ! brew list --cask pycharm &>/dev/null; then
	echo "PyCharm not found. Installing..."
	brew install --cask pycharm
else
	echo "PyCharm already exists. Skipping install."
fi

# Configure ~/.zshrc only once (avoid duplicate entries)
ZSHRC="$HOME/.zshrc"
if ! grep -q 'pyenv init' "$ZSHRC"; then
	echo "Updating ~/.zshrc for pyenv and direnv and shell enhancements..."
	cat <<'EOF' >> "$ZSHRC"

# === Dev Env Setup ===
eval "$(pyenv init --path)"
eval "$(direnv hook zsh)"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF
else
	echo "~/.zshrc already configured for dev environment."
fi

echo "Bootstrap complete. Restart your terminal or run 'source ~/.zshrc' to apply changes."
