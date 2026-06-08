#!/bin/bash
set -e

ROM_FILE="$1"
OUTPUT_DIR="$2"

mkdir -p "$OUTPUT_DIR"

echo "🔧 Running DumprX..."

# Telegram update
if [ -n "$TELEGRAM_CHAT_ID" ]; then
    python3 "$GITHUB_WORKSPACE/.github/scripts/03_telegram.py" step "Dump" "running" 2>/dev/null || true
fi

# Clone DumprX
rm -rf /tmp/DumprX
git clone --depth=1 https://github.com/DumprX/DumprX.git /tmp/DumprX

cd /tmp/DumprX
chmod +x dumper.sh setup.sh
export TERM=xterm

# Run dumper
set +e
./dumper.sh "$ROM_FILE"
CODE=$?
set -e

# If dumper failed but output exists, continue
if [ "$CODE" -ne 0 ]; then
    if [ -d /tmp/DumprX/out ] && [ -n "$(find /tmp/DumprX/out -type f | head -n1)" ]; then
        echo "⚠️ DumprX returned non-zero but output exists. Continuing."
    else
        echo "❌ DumprX failed and no output found."
        exit "$CODE"
    fi
fi

# Copy output
if [ -d /tmp/DumprX/out ]; then
    rsync -a /tmp/DumprX/out/ "$OUTPUT_DIR/"
else
    echo "❌ Output directory not found"
    exit 1
fi

# Add metadata
{
    echo "rom_url=$URL"
    echo "dumped_at=$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo "workflow_run=${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
    echo "runner=os=$(uname -o), arch=$(uname -m)"
} > "$OUTPUT_DIR/_dump_info.txt"

# Telegram update
if [ -n "$TELEGRAM_CHAT_ID" ]; then
    COUNT=$(find "$OUTPUT_DIR" -type f | wc -l)
    python3 "$GITHUB_WORKSPACE/.github/scripts/03_telegram.py" step "Dump" "done" "Files: $COUNT" 2>/dev/null || true
fi

echo "✅ Dump complete: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"
