#!/bin/bash

runnable() {
	type "$1" 1>/dev/null 2>/dev/null
}

if runnable brew; then
	echo "Homebrew exists"
else
	echo "Try to install Homebrew for you now"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installing..."

brew tap createchstudio/cpc
brew install cpc

if runnable cpc; then
	echo "Installing dependencies"
	cpc -i

	echo "Install CAIE_Code successfully"
else
	echo "Failed to install CAIE_Code, try to install manually. "
fi
