<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=200&section=header&text=DumperX%20Pro&fontSize=70&fontAlignY=35&animation=twinkling&desc=Ultimate%20ROM%20Dumper%20%7C%20Tree%20Generator%20%7C%20All%20Devices&descAlignY=55&descAlign=50" width="100%" />
</p>

<div align="center">

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/Il103/Stock-rom-dumber/dump.yml?branch=main&style=for-the-badge&logo=github-actions&logoColor=white&label=BUILD&color=00C853)](https://github.com/Il103/Stock-rom-dumber/actions)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/Il103/Stock-rom-dumber?style=for-the-badge&logo=github&logoColor=white&color=FF6D00)](https://github.com/Il103/Stock-rom-dumber/releases)
[![GitHub stars](https://img.shields.io/github/stars/Il103/Stock-rom-dumber?style=for-the-badge&logo=github&logoColor=white&color=FFD600)](https://github.com/Il103/Stock-rom-dumber/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Il103/Stock-rom-dumber?style=for-the-badge&logo=github&logoColor=white&color=2979FF)](https://github.com/Il103/Stock-rom-dumber/network)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge&logo=apache&logoColor=white&color=00E676)](LICENSE)

</div>

<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=22&duration=3000&pause=1000&color=00E676&center=true&vCenter=true&width=600&lines=Dump+Any+ROM+in+Minutes;Generate+Device+%2F+Recovery+%2F+Kernel+Trees;Support+All+Recovery+Branches;TWRP+%7C+PBRP+%7C+OrangeFox+%7C+SHRP+%7C+OFRP;Live+Telegram+Notifications;GitHub+%2B+GitGud+Upload;Auto-Detect+Touch+ICs+%26+Panels" alt="Typing SVG" />
</p>

---

## 🚀 What is DumperX?

**DumperX Pro** is the ultimate automated ROM dumping tool powered by **GitHub Actions**. It dumps any stock ROM, generates fully-featured Android trees, and uploads everything automatically.

<p align="center">
  <img src="https://media.giphy.com/media/3o7TKSjRrfIPjeiVyM/giphy.gif" width="400" />
</p>

---

## ✨ Features

| Feature | Status | Description |
|---------|--------|-------------|
| 🌍 **Universal ROM Support** | ✅ | Any stock ROM from any manufacturer |
| ⚡ **Ultra-Stable Download** | ✅ | aria2c with 16 connections + resume |
| ☁️ **GitGud.io Upload** | ✅ | Bypass GitHub 100MB limit |
| 💬 **Telegram Bot Live** | ✅ | Real-time updates with inline keyboards |
| 🌳 **Device Tree** | ✅ | Full AOSP/LineageOS compatible |
| 🚑 **Recovery Tree** | ✅ | TWRP, PBRP, OrangeFox, SHRP, OFRP |
| 🐧 **Kernel Tree** | ✅ | Auto-extract kernel + DTB |
| 🔍 **Hardware Detection** | ✅ | Auto-detect touch ICs, panels, SoC |
| 🧪 **Full Verification** | ✅ | Check every file + tree integrity |
| 🗜️ **Compression** | ✅ | xz compression for images |
| 📂 **FS Extraction** | ✅ | Extract filesystem contents |

---

## 🎯 Supported Recovery Branches

<div align="center">

| Recovery | Branch | Manifest |
|----------|--------|----------|
| <img src="https://img.shields.io/badge/TWRP-Official-000000?style=flat-square&logo=android&logoColor=white&color=1E88E5" /> | `twrp`, `twrp-12.1`, `twrp-11.0` | [minimal-manifest-twrp](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp) |
| <img src="https://img.shields.io/badge/PBRP-PitchBlack-000000?style=flat-square&logo=android&logoColor=white&color=7B1FA2" /> | `pbrp`, `pbrp-12.1` | [PitchBlackRecoveryProject](https://github.com/PitchBlackRecoveryProject/manifest_pb) |
| <img src="https://img.shields.io/badge/OrangeFox-Official-000000?style=flat-square&logo=android&logoColor=white&color=FF6D00" /> | `orangefox`, `orangefox-12.1`, `orangefox-11.0` | [OrangeFox](https://gitlab.com/OrangeFox/Manifest.git) |
| <img src="https://img.shields.io/badge/SHRP-SkyHawk-000000?style=flat-square&logo=android&logoColor=white&color=00E676" /> | `shrp` | [SHRP](https://github.com/SHRP/manifest.git) |
| <img src="https://img.shields.io/badge/OFRP-Official-000000?style=flat-square&logo=android&logoColor=white&color=FF1744" /> | `ofrp` | [OrangeFox](https://gitlab.com/OrangeFox/Manifest.git) |

</div>

---

## 📱 Recovery Boot Source Selection

<p align="center">
  <img src="https://media.giphy.com/media/l0HlNQ03J5JxX6lva/giphy.gif" width="300" />
</p>

DumperX intelligently detects and supports all recovery boot sources:

| Source | Use Case | Auto-Detect |
|--------|----------|-------------|
| `recovery.img` | Traditional recovery partition | ✅ |
| `vendor_boot.img` | Modern A/B devices (Android 12+) | ✅ |
| `boot.img` | Boot-as-recovery devices | ✅ |

---

## 🛠️ Setup Guide

### 1️⃣ Fork the Repository
<p align="center">
  <img src="https://img.shields.io/badge/-CLICK%20TO%20FORK-181717?style=for-the-badge&logo=github&logoColor=white" />
</p>

Click the **Fork** button above ☝️

### 2️⃣ Configure Secrets (Optional)
Go to **Settings → Secrets and variables → Actions → New repository secret**

| Secret | Required For | How to Get |
|--------|-------------|------------|
| `GITGUD_TOKEN` | Upload to GitGud.io | [gitgud.io → Settings → Access Tokens](https://gitgud.io) |
| `TELEGRAM_CHAT_ID` | Telegram notifications | Message [@userinfobot](https://t.me/userinfobot) |

### 3️⃣ Run Workflow
<p align="center">
  <img src="https://media.giphy.com/media/3o7TKMt1VVNkHV2Pa8/giphy.gif" width="300" />
</p>

1. Go to **Actions** tab
2. Select **🚀 DumperX Pro**
3. Click **Run workflow**
4. Fill the form:

```yaml
ROM URL: https://needrom.com/.../rom.zip
Device Codename: gta4l (or leave empty for auto-detect)
Telegram Chat ID: 123456789 (optional)
GitGud Token: glpat-xxxxxxxx (optional)
Upload Target: both (GitHub + GitGud)
Generate Device Tree: ✅
Generate Recovery Tree: ✅
Recovery Branch: twrp (or pbrp, orangefox, shrp, ofrp)
Recovery Boot Source: auto (or recovery, vendor_boot, boot)
Generate Kernel Tree: ✅
```

---

## 🤖 Telegram Bot Features

<p align="center">
  <img src="https://img.shields.io/badge/Telegram-@DumperXBot-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white" />
</p>

Our bot sends **live updates** with inline keyboards:

- 🚀 **Start Notification** - Job begins
- ⬇️ **Download Progress** - File size & speed
- 🔧 **Dump Status** - Files extracted
- ☁️ **Upload Status** - GitHub + GitGud
- 🌳 **Tree Generation** - Device/Recovery/Kernel
- ✅ **Final Report** - All links & status

**Inline Buttons:**
- 📊 **View Run** → Opens GitHub Actions
- 📁 **View Dump** → Opens dumped branch
- 🌳 **View Trees** → Opens tree repositories
- 📖 **Instructions** → Opens this README

---

## ☁️ GitGud.io Setup

<p align="center">
  <img src="https://media.giphy.com/media/3o7TKU8vG4m8p7yP0I/giphy.gif" width="300" />
</p>

**Why GitGud?** GitHub limits files to 100MB in repositories. GitGud.io has **no such limits**!

1. Register at [gitgud.io](https://gitgud.io)
2. Go to **User Settings → Access Tokens**
3. Create token with `api` scope
4. Paste token in workflow input

---

## 🌳 Generated Trees Details

### 📱 Device Tree
```
android_device_<vendor>_<codename>
├── BoardConfig.mk      ← Full board configuration
├── device.mk           ← Device packages & props
├── Android.bp          ← Soong namespace
├── AndroidProducts.mk  ← Lunch targets
├── aosp_<codename>.mk  ← Product makefile
├── recovery.fstab      ← Recovery fstab
├── prebuilt/
│   ├── kernel          ← Extracted kernel
│   └── dtbo.img        ← DTBO image
└── sepolicy/           ← SELinux policies
```

### 🚑 Recovery Tree (TWRP Example)
```
android_recovery_<vendor>_<codename>
├── BoardConfig.mk      ← Recovery-specific config
├── recovery.fstab      ← Recovery mount points
├── AndroidProducts.mk  ← Lunch choices
├── twrp_<codename>.mk  ← TWRP product config
├── Android.bp          ← Soong namespace
└── prebuilt/
    ├── recovery.img    ← Recovery/vendor_boot image
    └── dtbo.img        ← DTBO image
```

### 🐧 Kernel Tree
```
android_kernel_<vendor>_<codename>
├── prebuilt/
│   ├── Image.gz        ← Extracted kernel
│   └── dtb             ← Device tree blob
├── Android.bp
└── Android.mk
```

---

## 🔍 Auto-Detection Features

DumperX automatically detects:

| Component | Detection Method |
|-----------|---------------|
| **SoC/Platform** | Codename patterns + build.prop |
| **Touch ICs** | Vendor partition driver search |
| **Panel Info** | Display driver names |
| **Kernel Version** | Boot image string extraction |
| **DTB** | Automatic extraction from boot |
| **Partition Sizes** | Boot image header analysis |
| **A/B or A-only** | Partition table analysis |

---

## 📋 Supported ROM Sources

<div align="center">

![Needrom](https://img.shields.io/badge/Needrom-Direct%20Links-FF6D00?style=for-the-badge)
![GitHub](https://img.shields.io/badge/GitHub-Releases-181717?style=for-the-badge&logo=github)
![GitLab](https://img.shields.io/badge/GitLab-Releases-FC6D26?style=for-the-badge&logo=gitlab)
![Google%20Drive](https://img.shields.io/badge/Google%20Drive-Direct-4285F4?style=for-the-badge&logo=google-drive)
![MediaFire](https://img.shields.io/badge/MediaFire-Direct-FF6D00?style=for-the-badge)
![Any%20Direct%20HTTP](https://img.shields.io/badge/Any%20HTTP%2FHTTPS-Direct-00E676?style=for-the-badge)

</div>

---

## ⚡ Download Protocols

| Protocol | Connections | Resume | Retry |
|----------|-------------|--------|-------|
| **aria2c** | 16 parallel | ✅ | 10x |
| **wget** | 1 | ✅ | 10x |
| **curl** | 1 | ✅ | 10x |

---

## 📝 Advanced Options

| Option | Description | Default |
|--------|-------------|---------|
| `compress_images` | xz compress .img files | `false` |
| `extract_contents` | Extract filesystem from images | `false` |
| `split_large_files` | Split >100MB for GitHub | `true` |
| `use_aria2c` | Use aria2c downloader | `true` |

---

## 🛡️ Limits & Notes

| Platform | File Size Limit | Repo Size |
|----------|-----------------|-----------|
| **GitHub Repo** | 100MB per file | ~2GB recommended |
| **GitHub Releases** | 2GB per file | Unlimited |
| **GitGud.io** | No limit | No limit |
| **GitHub Actions** | 6 hours runtime | ~50GB disk |

---

## 🎬 Demo

<p align="center">
  <img src="https://media.giphy.com/media/3o7TKSjRrfIPjeiVyM/giphy.gif" width="300" />
  <img src="https://media.giphy.com/media/l0HlNQ03J5JxX6lva/giphy.gif" width="300" />
</p>

---

## 🙏 Credits

<div align="center">

| Project | Link |
|---------|------|
| **Original DumprX** | [DumprX Team](https://github.com/DumprX/DumprX) |
| **TWRP** | [TeamWin](https://github.com/minimal-manifest-twrp) |
| **PBRP** | [PitchBlack](https://github.com/PitchBlackRecoveryProject) |
| **OrangeFox** | [OrangeFox Team](https://gitlab.com/OrangeFox) |
| **SHRP** | [SkyHawk](https://github.com/SHRP) |

</div>

---

## 📜 License

```
Copyright (C) 2024 DumperX Pro

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=100&section=footer&animation=twinkling" width="100%" />
</p>

<div align="center">
  <b>Made with ❤️ by DumperX Pro Team</b>
  <br>
  <i>Dump Everything. Build Anything.</i>
</div>
