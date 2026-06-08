#!/bin/bash
set -e

echo "🛠️ Setting up Ultra Environment..."

# Update system
sudo apt-get update -qq

# Core tools
sudo apt-get install -y --no-install-recommends     git git-lfs curl wget jq file rsync unzip tar zip p7zip-full p7zip-rar     python3 python3-pip python3-venv xz-utils zstd brotli     liblz4-tool gawk detox cpio rename bc bison flex     device-tree-compiler libfdt-dev     android-sdk-libsparse-utils e2fsprogs e2tools erofs-utils     libxml2-utils openssl ccache     gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi     binutils-aarch64-linux-gnu binutils-arm-linux-gnueabi     aria2

# Install uv (fast Python package manager)
if ! command -v uv >/dev/null 2>&1; then
    curl -fsSL https://astral.sh/uv/install.sh | sh
    echo "$HOME/.local/bin" >> "$GITHUB_PATH"
    export PATH="$HOME/.local/bin:$PATH"
fi

# Install modern Python tools
pip3 install --quiet --upgrade pip
pip3 install --quiet     aospdtgen     twrpdtgen     extract-dtb     protobuf

# Install payload-dumper-go (for OTA payloads)
if ! command -v payload-dumper-go >/dev/null 2>&1; then
    PAYLOAD_URL=$(curl -s https://api.github.com/repos/vm03/payload_dumper/releases/latest |         jq -r '.assets[] | select(.name | contains("linux")) | .browser_download_url' | head -1)
    if [ -n "$PAYLOAD_URL" ]; then
        wget -q -O /tmp/payload_dumper.zip "$PAYLOAD_URL"
        unzip -q /tmp/payload_dumper.zip -d /tmp/payload_dumper
        sudo mv /tmp/payload_dumper/payload_dumper /usr/local/bin/payload-dumper-go 2>/dev/null ||         sudo mv /tmp/payload_dumper/payload-dumper-go /usr/local/bin/payload-dumper-go 2>/dev/null || true
        sudo chmod +x /usr/local/bin/payload-dumper-go 2>/dev/null || true
    fi
fi

# Install mkdtboimg
if ! command -v mkdtboimg >/dev/null 2>&1; then
    wget -q -O /tmp/mkdtboimg https://github.com/LineageOS/android_system_libufdt/releases/download/latest/mkdtboimg 2>/dev/null || true
    if [ -f /tmp/mkdtboimg ]; then
        sudo mv /tmp/mkdtboimg /usr/local/bin/
        sudo chmod +x /usr/local/bin/mkdtboimg
    fi
fi

# Install simg2img if not present
if ! command -v simg2img >/dev/null 2>&1; then
    sudo apt-get install -y --no-install-recommends android-sdk-libsparse-utils
fi

# Configure git
git config --global user.name "DumperX-Pro[bot]"
git config --global user.email "dumperx@users.noreply.github.com"
git config --global init.defaultBranch main
git config --global core.compression 0
git config --global http.version HTTP/1.1
git config --global http.postBuffer 524288000

# Install GitHub CLI
if ! command -v gh >/dev/null 2>&1; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update -qq && sudo apt-get install -y gh
fi

# Verify installations
echo "✅ Installed tools:"
echo "aria2c: $(aria2c --version | head -1)"
echo "7z: $(7z | head -2 | tail -1)"
echo "zstd: $(zstd --version | head -1)"
echo "python3: $(python3 --version)"
echo "git-lfs: $(git lfs version | head -1)"
echo "gh: $(gh --version | head -1)"

echo "🎉 Environment setup complete!"
