# HyperOS ROM Dumper

> Automated GitHub Actions workflow to dump **HyperOS Recovery ROMs** (payload.bin) and **HyperOS Fastboot ROMs** (sparse images) â€” and upload all extracted partition `.img` files directly to GitHub Releases.

---

## Features

| Feature | Details |
|---------|---------|
| ðŸ“¦ Recovery ROM | Extracts `payload.bin` from ZIP â†’ dumps all partitions via `payload-dumper-go` |
| âš¡ Fastboot ROM | Extracts `.tgz` / `.zip` â†’ auto-detects sparse images â†’ converts to raw via `simg2img` |
| ðŸš€ Fast download | `aria2c` with 16 parallel connections |
| ðŸ“¤ Auto upload | All `.img` files + `SHA256SUMS.txt` â†’ GitHub Release |
| ðŸ—œï¸ Optional xz | Compress images before upload to reduce storage |
| ðŸ§¹ Disk cleanup | Frees ~20 GB on runner before extraction |

---

## Usage

### 1 â€” Run the workflow

Go to **Actions â†’ HyperOS ROM Dumper â†’ Run workflow**

| Input | Required | Description |
|-------|----------|-------------|
| `rom_type` | âœ… | `recovery` (ZIP+payload.bin) or `fastboot` (TGZ/ZIP+img) |
| `rom_url` | âœ… | Direct download link to the ROM file |
| `release_tag` | âœ… | Release tag to create (e.g. `HyperOS-spinel-V816.0.4.0`) |
| `device_name` | âŒ | Device codename for labeling (e.g. `spinel`) |
| `convert_sparse` | âŒ | Convert sparse â†’ raw images (fastboot only, default: `true`) |
| `compress_images` | âŒ | Compress output with xz before upload (default: `false`) |

### 2 â€” Download the images

Find the uploaded images in the **Releases** section of this repository.

---

## ROM Type Guide

### Recovery ROM
Xiaomi recovery ROMs are typically:
```
miui_SPINEL_xxx_xxx_qcom.zip
  â””â”€â”€ payload.bin        â† contains all partition images
```
Supported payload versions: Android 9+ (Chrome OS payload format).

### Fastboot ROM
Xiaomi fastboot ROMs are typically:
```
spinel_images_Vxxx_xxx.tgz
  â”œâ”€â”€ system.img         â† sparse Android img
  â”œâ”€â”€ vendor.img
  â”œâ”€â”€ boot.img
  â”œâ”€â”€ ...
  â””â”€â”€ flash_all.sh
```
The workflow extracts all `.img` files and optionally converts them from Android sparse format to raw ext4/erofs.

---

## Extracted Partitions (typical HyperOS device)

| Partition | Description |
|-----------|-------------|
| `boot.img` | Kernel + ramdisk |
| `vendor_boot.img` | Vendor ramdisk |
| `init_boot.img` | Generic ramdisk (GKI) |
| `system.img` | Android system |
| `system_ext.img` | System extensions |
| `vendor.img` | Vendor HALs |
| `product.img` | Product apps |
| `odm.img` | ODM overlay |
| `mi_ext.img` | Xiaomi extensions |
| `vbmeta.img` | Verified boot metadata |
| `dtbo.img` | Device tree overlay |

---

## Requirements

- No extra secrets needed â€” uses the built-in `GITHUB_TOKEN`
- Runner: `ubuntu-latest` (GitHub-hosted, ~14 GB free disk by default â†’ ~34 GB after cleanup)
- Large ROMs (>10 GB uncompressed) may still hit disk limits â€” enable `compress_images: true` in that case

---

## Notes

- GitHub Releases supports files up to **2 GB each**. Individual large images (e.g. `system.img` > 2 GB) should use `compress_images: true` to bring them under the limit.
- The workflow will always generate `SHA256SUMS.txt` alongside the images.
- Source ROM URL is preserved in the release notes for traceability.

---

## Credits

- [`payload-dumper-go`](https://github.com/ssut/payload-dumper-go) by ssut â€” fast payload.bin extractor
- `simg2img` from Android SDK sparse utils â€” sparse to raw converter
- [`softprops/action-gh-release`](https://github.com/softprops/action-gh-release) â€” release uploader
