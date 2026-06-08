#!/bin/bash
set -e

URL="$1"
OUTPUT_DIR="$2"
USE_ARIA2C="${3:-true}"

# Trim whitespace from URL
URL=$(echo "$URL" | sed 's/[[:space:]]*$//')

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# Extract filename from URL
FILENAME=$(basename "$URL" | cut -d'?' -f1 | cut -d'#' -f1)
if [ -z "$FILENAME" ] || [ "$FILENAME" = "" ]; then
    FILENAME="rom.zip"
fi

echo "Downloading ROM..."
echo "   URL: $URL"
echo "   Output: $OUTPUT_DIR/$FILENAME"

# Telegram update
if [ -n "$TELEGRAM_CHAT_ID" ]; then
    python3 "$GITHUB_WORKSPACE/.github/scripts/03_telegram.py" step "Download" "running" "File: $FILENAME" 2>/dev/null || true
fi

# Check if it's a Google Drive link
if echo "$URL" | grep -qE "drive\.google\.com|docs\.google\.com"; then
    echo "   Detected Google Drive link"

    # Extract file ID
    FILE_ID=$(echo "$URL" | sed -n 's/.*\/d\/\([^\/]*\).*/\1/p')
    if [ -z "$FILE_ID" ]; then
        FILE_ID=$(echo "$URL" | sed -n 's/.*id=\([^&]*\).*/\1/p')
    fi

    if [ -n "$FILE_ID" ]; then
        echo "   File ID: $FILE_ID"

        # Install gdown if not present
        if ! command -v gdown >/dev/null 2>&1; then
            echo "   Installing gdown..."
            pip3 install --quiet gdown
        fi

        # Download with gdown
        echo "   Downloading with gdown..."
        gdown --id "$FILE_ID" -O "$FILENAME" --no-cookies && DOWNLOAD_SUCCESS=true || DOWNLOAD_SUCCESS=false

        if [ "$DOWNLOAD_SUCCESS" = "true" ] && [ -f "$FILENAME" ] && [ -s "$FILENAME" ]; then
            echo "gdown download successful"
        else
            echo "gdown failed, trying direct download..."
            rm -f "$FILENAME"
            DOWNLOAD_SUCCESS=false
        fi
    fi
fi

# If not Google Drive or gdown failed, try normal download
if [ "$DOWNLOAD_SUCCESS" != "true" ]; then
    # Common headers to mimic browser
    USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
    REFERER="https://www.needrom.com/"

    # Try aria2c first
    if [ "$USE_ARIA2C" = "true" ] && command -v aria2c >/dev/null 2>&1; then
        echo "   Method: aria2c (with browser headers)"

        aria2c -x4 -s4 -j1 -c -m0 \
            --summary-interval=30 \
            --console-log-level=warn \
            --download-result=full \
            --file-allocation=none \
            --timeout=600 \
            --retry-wait=30 \
            --max-tries=10 \
            --allow-overwrite=true \
            --user-agent="$USER_AGENT" \
            --referer="$REFERER" \
            --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" \
            --header="Accept-Language: en-US,en;q=0.5" \
            --check-certificate=false \
            -o "$FILENAME" \
            "$URL" && DOWNLOAD_SUCCESS=true || DOWNLOAD_SUCCESS=false

        if [ "$DOWNLOAD_SUCCESS" = "true" ] && [ -f "$FILENAME" ] && [ -s "$FILENAME" ]; then
            echo "aria2c download successful"
        else
            echo "aria2c failed, trying wget..."
            rm -f "$FILENAME"
            DOWNLOAD_SUCCESS=false
        fi
    fi

    # Fallback to wget
    if [ "$DOWNLOAD_SUCCESS" != "true" ]; then
        echo "   Method: wget (with browser headers)"

        wget --user-agent="$USER_AGENT" \
             --referer="$REFERER" \
             --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" \
             --header="Accept-Language: en-US,en;q=0.5" \
             --timeout=600 \
             --tries=10 \
             --no-check-certificate \
             -c \
             -O "$FILENAME" \
             "$URL" && DOWNLOAD_SUCCESS=true || DOWNLOAD_SUCCESS=false

        if [ "$DOWNLOAD_SUCCESS" = "true" ] && [ -f "$FILENAME" ] && [ -s "$FILENAME" ]; then
            echo "wget download successful"
        else
            echo "wget failed, trying curl..."
            rm -f "$FILENAME"
            DOWNLOAD_SUCCESS=false
        fi
    fi

    # Fallback to curl
    if [ "$DOWNLOAD_SUCCESS" != "true" ]; then
        echo "   Method: curl (with browser headers)"

        curl -L -C - \
             --max-time 3600 \
             --retry 10 \
             --retry-delay 30 \
             -A "$USER_AGENT" \
             -e "$REFERER" \
             -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" \
             -H "Accept-Language: en-US,en;q=0.5" \
             -k \
             -o "$FILENAME" \
             "$URL" && DOWNLOAD_SUCCESS=true || DOWNLOAD_SUCCESS=false
    fi
fi

# Verify file
if [ ! -f "$FILENAME" ] || [ ! -s "$FILENAME" ]; then
    echo "Download failed: file not found or empty"
    echo "This usually means:"
    echo "  1. The download link expired"
    echo "  2. The server blocks GitHub Actions IP addresses"
    echo "  3. The file requires a premium/subscription"
    echo "  4. Google Drive virus scan warning (large files)"
    echo ""
    echo "Solutions:"
    echo "  - For Google Drive: Make sure the file is public (Anyone with link)"
    echo "  - For Google Drive large files: Use 'gdown' or host elsewhere"
    echo "  - Get a fresh download link"
    echo "  - Upload the ROM to your own server or cloud storage"
    exit 1
fi

SIZE=$(du -h "$FILENAME" | cut -f1)
echo "Download complete: $FILENAME ($SIZE)"

# Check if it's a .rar file and extract if needed
if echo "$FILENAME" | grep -qi "\.rar$"; then
    echo "Detected .rar file, extracting..."
    if command -v unrar >/dev/null 2>&1; then
        unrar x "$FILENAME" "$OUTPUT_DIR/"
    elif command -v 7z >/dev/null 2>&1; then
        7z x "$FILENAME" -o"$OUTPUT_DIR/"
    else
        echo "Warning: .rar file detected but unrar/7z not installed"
        echo "The dumper may not be able to process this file"
    fi
fi

# Telegram update
if [ -n "$TELEGRAM_CHAT_ID" ]; then
    python3 "$GITHUB_WORKSPACE/.github/scripts/03_telegram.py" step "Download" "done" "Size: $SIZE" 2>/dev/null || true
fi
