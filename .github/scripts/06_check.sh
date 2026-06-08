#!/bin/bash
set -e

DUMP_DIR="$1"
CODE="$2"

REPORT="/tmp/check_report.md"
echo "## ✅ Verification Report" > "$REPORT"
echo "" >> "$REPORT"
echo "Generated: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" >> "$REPORT"
echo "" >> "$REPORT"

ERRORS=0
WARNINGS=0

check_file() {
    local file="$1"
    local desc="$2"
    local required="$3"

    if [ -f "$file" ]; then
        SIZE=$(du -h "$file" | cut -f1)
        echo "- ✅ $desc: \`$(basename "$file")\` ($SIZE)" >> "$REPORT"
        return 0
    else
        if [ "$required" = "required" ]; then
            echo "- ❌ $desc: **MISSING** (Required)" >> "$REPORT"
            ((ERRORS++))
            return 1
        else
            echo "- ⚠️ $desc: Missing (Optional)" >> "$REPORT"
            ((WARNINGS++))
            return 1
        fi
    fi
}

echo "### 📱 Dump Files Check" >> "$REPORT"
echo "" >> "$REPORT"

check_file "$DUMP_DIR/boot.img" "Boot Image" "required"
check_file "$DUMP_DIR/recovery.img" "Recovery Image" "optional"
check_file "$DUMP_DIR/system.img" "System Image" "required"
check_file "$DUMP_DIR/vendor.img" "Vendor Image" "required"
check_file "$DUMP_DIR/product.img" "Product Image" "optional"
check_file "$DUMP_DIR/dtbo.img" "DTBO Image" "optional"
check_file "$DUMP_DIR/vbmeta.img" "VBMeta Image" "optional"
check_file "$DUMP_DIR/vbmeta_system.img" "VBMeta System" "optional"
check_file "$DUMP_DIR/super.img" "Super Image" "optional"
check_file "$DUMP_DIR/README.md" "Dump README" "required"

if [ ! -f "$DUMP_DIR/recovery.img" ] && [ -f "$DUMP_DIR/recovery_from_vendor_boot.img" ]; then
    echo "- 🚑 Recovery fallback from vendor_boot detected" >> "$REPORT"
fi

echo "" >> "$REPORT"
echo "### 📊 File Statistics" >> "$REPORT"
echo "" >> "$REPORT"

TOTAL_FILES=$(find "$DUMP_DIR" -type f | wc -l)
TOTAL_SIZE=$(du -sh "$DUMP_DIR" | cut -f1)
LARGE_FILES=$(find "$DUMP_DIR" -type f -size +100M | wc -l)

echo "- Total files: $TOTAL_FILES" >> "$REPORT"
echo "- Total size: $TOTAL_SIZE" >> "$REPORT"
echo "- Files >100MB: $LARGE_FILES" >> "$REPORT"

echo "" >> "$REPORT"
echo "### 🔍 Issues Found" >> "$REPORT"
echo "" >> "$REPORT"

if [ "$ERRORS" -gt 0 ]; then
    echo "- **$ERRORS** critical errors found" >> "$REPORT"
else
    echo "- No critical errors ✅" >> "$REPORT"
fi

if [ "$WARNINGS" -gt 0 ]; then
    echo "- **$WARNINGS** warnings (optional files missing)" >> "$REPORT"
else
    echo "- No warnings ✅" >> "$REPORT"
fi

echo "" >> "$REPORT"
echo "### 🌳 Tree Checks" >> "$REPORT"
echo "" >> "$REPORT"

for tree_dir in /tmp/trees/android_device_* /tmp/trees/android_recovery_* /tmp/trees/android_kernel_*; do
    [ -d "$tree_dir" ] || continue
    tree_name=$(basename "$tree_dir")

    if [ -f "$tree_dir/BoardConfig.mk" ]; then
        echo "- ✅ $tree_name: BoardConfig.mk present" >> "$REPORT"
    else
        echo "- ❌ $tree_name: BoardConfig.mk missing" >> "$REPORT"
    fi

    if [ -f "$tree_dir/Android.bp" ] || [ -f "$tree_dir/Android.mk" ]; then
        echo "- ✅ $tree_name: Build file present" >> "$REPORT"
    else
        echo "- ❌ $tree_name: No build file found" >> "$REPORT"
    fi
done

echo "" >> "$REPORT"
echo "---" >> "$REPORT"
echo "**Overall Status:** $([ "$ERRORS" -eq 0 ] && echo "✅ PASS" || echo "❌ FAIL")" >> "$REPORT"

cat "$REPORT"

if [ -n "$TELEGRAM_CHAT_ID" ]; then
    python3 "$GITHUB_WORKSPACE/.github/scripts/03_telegram.py" step "Check" "done" "Errors: $ERRORS, Warnings: $WARNINGS" 2>/dev/null || true
fi

exit $ERRORS
