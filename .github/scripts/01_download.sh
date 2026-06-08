#!/bin/bash
set -e

URL="$1"
OUTPUT_DIR="$2"
USE_ARIA2C="${3:-true}"

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# Extract filename from URL
FILENAME=$(basename "$URL" | cut -d'?' -f1 | cut -d'#' -f1)
if [ -z "$FILENAME" ] || [ "$FILENAME" = "" ]; then
    FILENAME="rom.zip"
fi

echo "⬇️ Downloading ROM..."
echo "   URL: $URL"
echo "   Output: $OUTPUT_DIR/$FILENAME"
echo "   Method: $([ "$USE_ARIA2C" = "true" ] && echo "aria2c (16 connections)" || echo "wget/curl fallback")"

# Telegram update
if [ -n "$TELEGRAM_CHAT_ID" ]; then
    python3 "$GITHUB_WORKSPACE/.github/scripts/03_telegram.py" step "Download" "running" "File: $FILENAME" 2>/dev/null || true
fi

# Download with aria2c (best for stability & speed)
if [ "$USE_ARIA2C" = "true" ] && command -v aria2c >/dev/null 2>&1; then
    aria2c -x16 -s16 -j5 -c -m0         --summary-interval=30         --console-log-level=warn         --download-result=full         --file-allocation=none         --timeout=600         --retry-wait=30         --max-tries=10         --allow-overwrite=true         -o "$FILENAME"         "$URL"
else
    # Fallback to wget with resume
    wget -c --progress=dot:giga --timeout=600 --tries=10         -O "$FILENAME" "$URL" ||     curl -L -C - --max-time 3600 --retry 10 --retry-delay 30         -o "$FILENAME" "$URL"
fi

# Verify file exists and has size
if [ ! -f "$FILENAME" ]; then
    echo "❌ Download failed: file not found"
    exit 1
fi

SIZE=$(du -h "$FILENAME" | cut -f1)
echo "✅ Download complete: $FILENAME ($SIZE)"

# Telegram update
if [ -n "$TELEGRAM_CHAT_ID" ]; then
    python3 "$GITHUB_WORKSPACE/.github/scripts/03_telegram.py" step "Download" "done" "Size: $SIZE" 2>/dev/null || true
fi
