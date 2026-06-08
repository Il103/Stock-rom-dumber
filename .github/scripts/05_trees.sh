#!/bin/bash
set -e

DUMP_DIR="$1"
BRAND="$2"
CODE="$3"
GEN_ALL="$4"
GEN_DEVICE="$5"
GEN_RECOVERY="$6"
GEN_KERNEL="$7"
GEN_VENDOR="${8:-false}"
RECOVERY_BRANCH="${9:-twrp}"
RECOVERY_BOOT_SOURCE="${10:-auto}"

GITHUB_TOKEN="${GITHUB_TOKEN:-$GH_TOKEN}"
[ -z "$GITHUB_TOKEN" ] && { echo "No GitHub token for trees"; exit 1; }

[ "$GEN_ALL" = "true" ] && { GEN_DEVICE=true; GEN_RECOVERY=true; GEN_KERNEL=true; GEN_VENDOR=true; }

VENDOR_UPPER=$(echo "$BRAND" | tr '[:lower:]' '[:upper:]')
VENDOR_LOWER="$BRAND"
CODE_UPPER=$(echo "$CODE" | tr '[:lower:]' '[:upper:]')
CODE_LOWER="$CODE"

TREE_BASE="/tmp/trees"
mkdir -p "$TREE_BASE"

echo "DumperX Tree Generator for $VENDOR_LOWER/$CODE..."
echo "   Recovery Branch: $RECOVERY_BRANCH"
echo "   Recovery Boot Source: $RECOVERY_BOOT_SOURCE"

# ANALYZE IMAGES
echo "Analyzing dumped images..."

BOOT_IMG=$(find "$DUMP_DIR" -maxdepth 2 -name "boot.img" | head -1 || true)
RECOVERY_IMG=$(find "$DUMP_DIR" -maxdepth 2 -name "recovery.img" | head -1 || true)
VENDOR_BOOT_IMG=$(find "$DUMP_DIR" -maxdepth 2 -name "vendor_boot.img" | head -1 || true)
DTBO_IMG=$(find "$DUMP_DIR" -maxdepth 2 -name "dtbo.img" | head -1 || true)
VENDOR_IMG=$(find "$DUMP_DIR" -maxdepth 2 -name "vendor.img" | head -1 || true)

# Auto-detect recovery boot source
if [ "$RECOVERY_BOOT_SOURCE" = "auto" ]; then
    if [ -f "$RECOVERY_IMG" ]; then
        RECOVERY_BOOT_SOURCE="recovery"
    elif [ -f "$VENDOR_BOOT_IMG" ]; then
        RECOVERY_BOOT_SOURCE="vendor_boot"
    elif [ -f "$BOOT_IMG" ]; then
        RECOVERY_BOOT_SOURCE="boot"
    fi
    echo "   Auto-detected recovery source: $RECOVERY_BOOT_SOURCE"
fi

# Detect platform from codename patterns
BOARD_PLATFORM="generic"
if [ "$BOARD_PLATFORM" = "generic" ] || [ -z "$BOARD_PLATFORM" ]; then
    case "$CODE" in
        *sm8*|*sdm8*|*kona*|*lahaina*|*taro*) BOARD_PLATFORM="sm8250" ;;
        *sm7*|*sdm7*|*lito*|*atoll*) BOARD_PLATFORM="sm7150" ;;
        *sm6*|*sdm6*|*trinket*) BOARD_PLATFORM="sm6150" ;;
        *mt6*|*mt7*|*mt8*) BOARD_PLATFORM="mt6768" ;;
        *unisoc*|*ums*) BOARD_PLATFORM="unisoc" ;;
        *exynos*) BOARD_PLATFORM="exynos" ;;
        *) BOARD_PLATFORM="sm8250" ;;
    esac
fi

echo "   Platform: $BOARD_PLATFORM"
echo "   Recovery Source: $RECOVERY_BOOT_SOURCE"

# DEVICE TREE
if [ "$GEN_DEVICE" = "true" ]; then
    echo "Generating Device Tree..."
    DT_DIR="$TREE_BASE/android_device_${VENDOR_LOWER}_${CODE}"
    mkdir -p "$DT_DIR"
    
    mkdir -p "$DT_DIR/prebuilt"
    [ -f "$BOOT_IMG" ] && cp "$BOOT_IMG" "$DT_DIR/prebuilt/kernel" 2>/dev/null || true
    [ -f "$DTBO_IMG" ] && cp "$DTBO_IMG" "$DT_DIR/prebuilt/dtbo.img" 2>/dev/null || true
    
    cat > "$DT_DIR/BoardConfig.mk" << 'BOF'
#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 DumperX Pro
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/${VENDOR_LOWER}/${CODE}

BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_INCORRECT_PARTITION_IMAGES := true
BUILD_BROKEN_MISSING_REQUIRED_MODULES := true
RELAX_USES_LIBRARY_CHECK := true

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a76

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := ${CODE}
TARGET_NO_BOOTLOADER := true

# Platform
TARGET_BOARD_PLATFORM := ${BOARD_PLATFORM}
TARGET_BOARD_PLATFORM_GPU := qcom-adreno

# Kernel
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_IMAGE_NAME := Image.gz
BOARD_KERNEL_SEPARATED_DTBO := true
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img

BOARD_KERNEL_CMDLINE := console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=0 loop.max_part=7 cgroup.memory=nokmem,nosocket firmware_class.path=/vendor/firmware_mnt/image

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 100663296
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_SUPER_PARTITION_SIZE := 9126805504
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext product vendor odm
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 9122611200

BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3221225472
BOARD_SYSTEM_EXTIMAGE_PARTITION_SIZE := 536870912
BOARD_PRODUCTIMAGE_PARTITION_SIZE := 1073741824
BOARD_VENDORIMAGE_PARTITION_SIZE := 1073741824
BOARD_ODMIMAGE_PARTITION_SIZE := 134217728

BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_USES_METADATA_PARTITION := true

# File systems
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EXT4 := true

TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_ODM := odm

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_USES_RECOVERY_AS_BOOT := false

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

# VNDK
BOARD_VNDK_VERSION := current

# Properties
TARGET_SYSTEM_PROP := $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP := $(DEVICE_PATH)/vendor.prop
TARGET_PRODUCT_PROP := $(DEVICE_PATH)/product.prop
TARGET_ODM_PROP := $(DEVICE_PATH)/odm.prop

# SELinux
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
BOARD_PLAT_PRIVATE_SEPOLICY_DIR += $(DEVICE_PATH)/sepolicy/private
BOARD_PLAT_PUBLIC_SEPOLICY_DIR += $(DEVICE_PATH)/sepolicy/public

# Recovery
TARGET_RECOVERY_DEVICE_MODULES += \
    libion

# Display
TARGET_SCREEN_DENSITY := 440
TARGET_USES_ION := true
TARGET_USES_NEW_ION_API := true

# Audio
AUDIO_FEATURE_ENABLED_AHAL_EXT := false
AUDIO_FEATURE_ENABLED_DLKM := false
AUDIO_FEATURE_ENABLED_DS2_DOLBY_DAP := false
AUDIO_FEATURE_ENABLED_DTS_EAGLE := false
AUDIO_FEATURE_ENABLED_DYNAMIC_LOG := false
AUDIO_FEATURE_ENABLED_COMPRESS_VOIP := false
AUDIO_FEATURE_ENABLED_EXTENDED_COMPRESS_FORMAT := false
AUDIO_FEATURE_ENABLED_GEF_SUPPORT := true
AUDIO_FEATURE_ENABLED_HW_ACCELERATED_EFFECTS := false
AUDIO_FEATURE_ENABLED_INSTANCE_ID := true
AUDIO_FEATURE_ENABLED_PROXY_DEVICE := true
AUDIO_FEATURE_ENABLED_SSR := false
AUDIO_FEATURE_ENABLED_SVA_MULTI_STAGE := true
BOARD_SUPPORTS_SOUND_TRIGGER := true
BOARD_USES_ALSA_AUDIO := true
BOF
    
    cat > "$DT_DIR/device.mk" << 'BOF'
#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 DumperX Pro
#
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

$(call inherit-product, device/${VENDOR_LOWER}/${CODE}/common.mk)

PRODUCT_NAME := aosp_${CODE}
PRODUCT_DEVICE := ${CODE}
PRODUCT_BRAND := ${VENDOR_UPPER}
PRODUCT_MODEL := ${CODE_UPPER}
PRODUCT_MANUFACTURER := ${VENDOR_UPPER}

PRODUCT_GMS_CLIENTID_BASE := android-${VENDOR_LOWER}

BUILD_FINGERPRINT := "${VENDOR_UPPER}/${CODE}/${CODE}:14/UP1A.230905.011/$(date +%s):user/release-keys"
PRIVATE_BUILD_DESC := "${CODE}-user $(date +%Y%m%d) release-keys"

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="${PRIVATE_BUILD_DESC}" \
    BUILD_FINGERPRINT="${BUILD_FINGERPRINT}"

TARGET_SCREEN_HEIGHT := 2400
TARGET_SCREEN_WIDTH := 1080

PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    system \
    system_ext \
    product \
    vendor \
    odm \
    vbmeta \
    vbmeta_system

PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

PRODUCT_USE_DYNAMIC_PARTITIONS := true

PRODUCT_PACKAGES += \
    fastbootd

PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay
BOF
    
    cat > "$DT_DIR/Android.bp" << 'BOF'
soong_namespace {
    imports: [
        "hardware/qcom-caf/sm8250",
        "hardware/qcom-caf/wlan",
        "vendor/qcom/opensource/commonsys-intf/display",
        "vendor/qcom/opensource/commonsys/display",
        "vendor/qcom/opensource/dataservices",
        "vendor/qcom/opensource/data-ipa-cfg-mgr",
        "hardware/xiaomi",
    ],
}
BOF
    
    cat > "$DT_DIR/AndroidProducts.mk" << 'BOF'
PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/aosp_${CODE}.mk

COMMON_LUNCH_CHOICES := \
    aosp_${CODE}-user \
    aosp_${CODE}-userdebug \
    aosp_${CODE}-eng
BOF
    
    cat > "$DT_DIR/aosp_${CODE}.mk" << 'BOF'
$(call inherit-product, device/${VENDOR_LOWER}/${CODE}/device.mk)

PRODUCT_NAME := aosp_${CODE}
PRODUCT_DEVICE := ${CODE}
BOF
    
    cat > "$DT_DIR/recovery.fstab" << 'BOF'
# Android fstab file.
system                                      /system      ext4    ro,barrier=1              wait,slotselect,avb=vbmeta_system,logical,first_stage_mount
system_ext                                  /system_ext  ext4    ro,barrier=1              wait,slotselect,avb=vbmeta_system,logical,first_stage_mount
product                                     /product     ext4    ro,barrier=1              wait,slotselect,avb=vbmeta_system,logical,first_stage_mount
vendor                                      /vendor      ext4    ro,barrier=1              wait,slotselect,avb,logical,first_stage_mount
odm                                         /odm         ext4    ro,barrier=1              wait,slotselect,avb,logical,first_stage_mount
boot                                        /boot        emmc    defaults                  first_stage_mount,nofail,slotselect
recovery                                    /recovery    emmc    defaults                  first_stage_mount,nofail,slotselect
cache                                       /cache       ext4    noatime,nosuid,nodev,nomblk_io_submit,errors=panic    wait,check
data                                        /data        f2fs    noatime,nosuid,nodev,discard,fsync_mode=nobarrier    latemount,wait,check,quota,reservedsize=128M
metadata                                    /metadata    ext4    noatime,nosuid,nodev,discard                          wait,check,formattable,first_stage_mount
misc                                        /misc        emmc    defaults                  defaults
BOF
    
    mkdir -p "$DT_DIR/sepolicy/vendor" "$DT_DIR/sepolicy/private" "$DT_DIR/sepolicy/public"
    mkdir -p "$DT_DIR/overlay/frameworks/base/core/res/res/values"
    mkdir -p "$DT_DIR/rootdir/etc"
    
    echo "Pushing Device Tree..."
    cd "$DT_DIR"
    git init
    git config user.name "DumperX-Pro[bot]"
    git config user.email "dumperx@users.noreply.github.com"
    git add -A
    git commit -m "device: ${VENDOR_LOWER}/${CODE} [$(date -u +%Y%m%d)]" || true
    
    REPO_NAME="android_device_${VENDOR_LOWER}_${CODE}"
    curl -s -X POST "https://api.github.com/user/repos" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "{\"name\":\"$REPO_NAME\",\"private\":false,\"description\":\"Device tree for ${VENDOR_UPPER} ${CODE} generated by DumperX Pro\"}" >/dev/null || true
    
    git remote add origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY_OWNER}/${REPO_NAME}.git" 2>/dev/null || \
    git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY_OWNER}/${REPO_NAME}.git"
    
    git push -f origin main || git push -f origin master || true
    echo "Device Tree: https://github.com/${GITHUB_REPOSITORY_OWNER}/${REPO_NAME}"
fi

# RECOVERY TREE (Multi-Branch Support)
if [ "$GEN_RECOVERY" = "true" ]; then
    echo "Generating Recovery Tree ($RECOVERY_BRANCH)..."
    RT_DIR="$TREE_BASE/android_recovery_${VENDOR_LOWER}_${CODE}"
    mkdir -p "$RT_DIR"
    
    RECOVERY_IMG_FILE=""
    case "$RECOVERY_BOOT_SOURCE" in
        recovery)
            RECOVERY_IMG_FILE=$(find "$DUMP_DIR" -maxdepth 2 -name "recovery.img" | head -1 || true)
            ;;
        vendor_boot)
            RECOVERY_IMG_FILE=$(find "$DUMP_DIR" -maxdepth 2 -name "vendor_boot.img" | head -1 || true)
            [ -z "$RECOVERY_IMG_FILE" ] && RECOVERY_IMG_FILE=$(find "$DUMP_DIR" -maxdepth 2 -name "recovery_from_vendor_boot.img" | head -1 || true)
            ;;
        boot)
            RECOVERY_IMG_FILE=$(find "$DUMP_DIR" -maxdepth 2 -name "boot.img" | head -1 || true)
            ;;
    esac
    
    case "$RECOVERY_BRANCH" in
        twrp|twrp-12.1|twrp-11.0)
            RECOVERY_NAME="TWRP"
            RECOVERY_REPO="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp"
            RECOVERY_BRANCH_NAME="twrp-12.1"
            [ "$RECOVERY_BRANCH" = "twrp-11.0" ] && RECOVERY_BRANCH_NAME="twrp-11.0"
            RECOVERY_MANIFEST="twrp"
            ;;
        pbrp|pbrp-12.1)
            RECOVERY_NAME="PBRP"
            RECOVERY_REPO="https://github.com/PitchBlackRecoveryProject/manifest_pb"
            RECOVERY_BRANCH_NAME="android-12.1"
            RECOVERY_MANIFEST="pbrp"
            ;;
        orangefox|orangefox-12.1|orangefox-11.0)
            RECOVERY_NAME="OrangeFox"
            RECOVERY_REPO="https://gitlab.com/OrangeFox/Manifest.git"
            RECOVERY_BRANCH_NAME="fox_12.1"
            [ "$RECOVERY_BRANCH" = "orangefox-11.0" ] && RECOVERY_BRANCH_NAME="fox_11.0"
            RECOVERY_MANIFEST="orangefox"
            ;;
        shrp)
            RECOVERY_NAME="SHRP"
            RECOVERY_REPO="https://github.com/SHRP/manifest.git"
            RECOVERY_BRANCH_NAME="shrp-12.1"
            RECOVERY_MANIFEST="shrp"
            ;;
        ofrp)
            RECOVERY_NAME="OFRP"
            RECOVERY_REPO="https://gitlab.com/OrangeFox/Manifest.git"
            RECOVERY_BRANCH_NAME="fox_12.1"
            RECOVERY_MANIFEST="orangefox"
            ;;
    esac
    
    cat > "$RT_DIR/BoardConfig.mk" << BOF
#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 DumperX Pro
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/${VENDOR_LOWER}/${CODE}

BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_MISSING_REQUIRED_MODULES := true
ALLOW_MISSING_DEPENDENCIES := true

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a76

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := ${CODE}
TARGET_NO_BOOTLOADER := true

# Platform
TARGET_BOARD_PLATFORM := ${BOARD_PLATFORM}
TARGET_BOARD_PLATFORM_GPU := qcom-adreno

# Kernel
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img
BOARD_KERNEL_CMDLINE := console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=0 loop.max_part=7 cgroup.memory=nokmem,nosocket firmware_class.path=/vendor/firmware_mnt/image
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_IMAGE_NAME := Image.gz

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 100663296
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_FLASH_BLOCK_SIZE := 262144

# Recovery
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_USES_RECOVERY_AS_BOOT := false
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
RECOVERY_SDCARD_ON_DATA := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
TW_MAX_BRIGHTNESS := 2047
TW_DEFAULT_BRIGHTNESS := 1200
TW_NO_SCREEN_BLANK := true
TW_SCREEN_BLANK_ON_BOOT := false
TW_Y_OFFSET := 80
TW_H_OFFSET := -80

# Encryption
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := 2099-12-31
PLATFORM_VERSION := 99.99.99
PLATFORM_VERSION_LAST_STABLE := 99.99.99
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
BOARD_USES_METADATA_PARTITION := true
BOARD_USES_QCOM_FBE_DECRYPTION := true

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    system \
    system_ext \
    product \
    vendor \
    odm \
    vbmeta \
    vbmeta_system

# Dynamic partitions
BOARD_SUPER_PARTITION_SIZE := 9126805504
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext product vendor odm
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 9122611200

# Properties
TARGET_RECOVERY_DEVICE_MODULES += \
    libion

# Touch
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_LOAD_VENDOR_MODULES := "adsp_loader_dlkm.ko qti_battery_charger.ko qti_battery_charger_main.ko"
TW_LOAD_VENDOR_BOOT_MODULES := true

# Display
TARGET_SCREEN_DENSITY := 440
TARGET_USES_ION := true

# Recovery Source
RECOVERY_BOOT_SOURCE := ${RECOVERY_BOOT_SOURCE}

# DumperX Pro generated
# Recovery: ${RECOVERY_NAME}
# Branch: ${RECOVERY_BRANCH}
# Boot Source: ${RECOVERY_BOOT_SOURCE}
BOF
    
    cat > "$RT_DIR/recovery.fstab" << 'BOF'
# mount point    fstype    device                  device2                  flags
/boot            emmc      /dev/block/bootdevice/by-name/boot                flags=backup=1;flashimg=1;slotselect
/recovery        emmc      /dev/block/bootdevice/by-name/recovery            flags=backup=1;flashimg=1;slotselect
/system          ext4      /dev/block/bootdevice/by-name/system              flags=backup=1;wipeingui;flashimg=1;slotselect
/system_ext      ext4      /dev/block/bootdevice/by-name/system_ext          flags=backup=1;wipeingui;flashimg=1;slotselect
/product         ext4      /dev/block/bootdevice/by-name/product             flags=backup=1;wipeingui;flashimg=1;slotselect
/vendor          ext4      /dev/block/bootdevice/by-name/vendor              flags=backup=1;wipeingui;flashimg=1;slotselect
/odm             ext4      /dev/block/bootdevice/by-name/odm                 flags=backup=1;wipeingui;flashimg=1;slotselect
/data            f2fs      /dev/block/bootdevice/by-name/userdata             flags=backup=1;wipeingui;storage
/cache           ext4      /dev/block/bootdevice/by-name/cache               flags=backup=1;wipeingui
/metadata        ext4      /dev/block/bootdevice/by-name/metadata            flags=backup=1;wipeingui
/sdcard          vfat      /dev/block/mmcblk1p1    /dev/block/mmcb
