#!/bin/bash
set -e

DUMP_DIR="$1"
TARGET="$2"
BRANCH="$3"
BRAND="$4"
CODE="$5"
SPLIT_LARGE="$6"

GITHUB_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"
RUN_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"

echo "☁️ Uploading Dump..."
echo "   Target: $TARGET"
echo "   Branch: $BRANCH"

if [ -n "$TELEGRAM_CHAT_ID" ]; then
    python3 "$GITHUB_WORKSPACE/.github/scripts/03_telegram.py" step "Upload" "running" "Target: $TARGET" 2>/dev/null || true
fi

upload_to_github() {
    echo "📤 Uploading to GitHub..."

    git fetch origin
    if git ls-remote --heads origin "$BRANCH" | grep -q "$BRANCH"; then
        git checkout -B "$BRANCH" "origin/$BRANCH"
    else
        git checkout --orphan "$BRANCH"
    fi

    find . -mindepth 1 -maxdepth 1 ! -name ".git" -exec rm -rf {} + 2>/dev/null || true

    rsync -a "$DUMP_DIR/" ./

    rm -f .gitattributes
    cat > .gitattributes << 'EOF'
*.img filter=lfs diff=lfs merge=lfs -text
*.img.xz filter=lfs diff=lfs merge=lfs -text
*.bin filter=lfs diff=lfs merge=lfs -text
*.new.dat filter=lfs diff=lfs merge=lfs -text
*.new.dat.br filter=lfs diff=lfs merge=lfs -text
*.payload filter=lfs diff=lfs merge=lfs -text
*.zip filter=lfs diff=lfs merge=lfs -text
*.tar filter=lfs diff=lfs merge=lfs -text
*.tar.gz filter=lfs diff=lfs merge=lfs -text
*.apk filter=lfs diff=lfs merge=lfs -text
*.apex filter=lfs diff=lfs merge=lfs -text
EOF

    find . -type f -size +90M -print0 | while IFS= read -r -d '' f; do
        rel="${f#./}"
        if ! grep -q "^$rel " .gitattributes 2>/dev/null; then
            echo "$rel filter=lfs diff=lfs merge=lfs -text" >> .gitattributes
        fi
    done

    if [ "$SPLIT_LARGE" = "true" ] && [ "$TARGET" = "github" ]; then
        find . -type f -size +100M -print0 | while IFS= read -r -d '' f; do
            rel="${f#./}"
            base="${rel%.*}"
            ext="${rel##*.}"
            if [ "$ext" = "$rel" ]; then ext=""; fi

            echo "Splitting: $rel"
            split -b 95M "$f" "${base}.part_"
            rm -f "$f"
            echo "#!/bin/bash" > "${base}.reassembly.sh"
            echo "cat ${base}.part_* > $rel" >> "${base}.reassembly.sh"
            chmod +x "${base}.reassembly.sh"
        done
    fi

    find . -type f -name "*.apk" -size +100M -delete 2>/dev/null || true

    git add -A
    git commit -m "dump: $BRAND-$CODE [$(date -u +%Y%m%d-%H%M%S)]" || true
    git push -f origin "$BRANCH" || {
        echo "⚠️ Push failed, retrying..."
        git push -f origin "$BRANCH"
    }

    echo "✅ GitHub upload complete: $GITHUB_URL/tree/$BRANCH"
}

upload_to_gitgud() {
    echo "📤 Uploading to GitGud.io..."

    if [ -z "$GITGUD_TOKEN" ]; then
        echo "❌ GitGud token not provided"
        return 1
    fi

    GITGUD_USER="oauth2"
    REPO_NAME="dump-${BRAND}-${CODE}"

    echo "Creating GitGud repo: $REPO_NAME"
    curl -s -X POST "https://gitgud.io/api/v4/projects"         -H "PRIVATE-TOKEN: $GITGUD_TOKEN"         -d "name=$REPO_NAME"         -d "visibility=public"         -d "initialize_with_readme=false" >/dev/null || true

    cd "$DUMP_DIR"
    git init
    git config user.name "DumperX-Pro"
    git config user.email "dump@dumperx.pro"

    git remote add gitgud "https://${GITGUD_USER}:${GITGUD_TOKEN}@gitgud.io/${GITGUD_USER}/${REPO_NAME}.git" 2>/dev/null ||     git remote set-url gitgud "https://${GITGUD_USER}:${GITGUD_TOKEN}@gitgud.io/${GITGUD_USER}/${REPO_NAME}.git"

    git add -A
    git commit -m "dump: $BRAND-$CODE [$(date -u +%Y%m%d-%H%M%S)]" || true

    for i in 1 2 3; do
        if git push -f gitgud main; then
            echo "✅ GitGud upload complete: https://gitgud.io/${GITGUD_USER}/${REPO_NAME}"
            break
        fi
        echo "Retry $i/3..."
        sleep 15
    done
}

case "$TARGET" in
    github)
        upload_to_github
        ;;
    gitgud)
        upload_to_gitgud
        ;;
    both)
        upload_to_github
        upload_to_gitgud
        ;;
esac

if [ -n "$TELEGRAM_CHAT_ID" ]; then
    python3 "$GITHUB_WORKSPACE/.github/scripts/03_telegram.py" step "Upload" "done" 2>/dev/null || true
fi
