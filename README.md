# Stock-rom-dumber

Stock-rom-dumber is a GitHub Actions workflow project that uses **DumprX** to dump and organize Stock ROM files automatically, then upload results to one or more destinations.

It is designed to make ROM dumping easy, repeatable, and scalable without manual server setup.

## Core Idea

Instead of doing everything manually, this repo gives you a full pipeline:

1. Download ROM from a direct URL.
2. Run DumprX dump process.
3. Build a smart branch name automatically.
4. Optionally compress images and extract filesystem contents.
5. Upload output to selected destinations:
   - GitHub branch (same repo)
   - GitLab
   - Gitea/Codeberg
   - SourceForge
   - Cloudflare R2

## Features

- Smart branch naming.
- Recovery fallback from `vendor_boot`.
- Optional `.img -> .img.xz` compression.
- Optional partition content extraction.
- Git LFS support for large files.
- Skip oversized APK files (`>100MB`).
- Auto-generated metadata files:
  - `_dump_info.txt`
  - `file_list.txt`
  - `*.sha256`

## Requirements

- A GitHub account.
- A fork of this repository.
- Destination secrets configured (only for external uploads).
- No local high-end hardware needed (runs on GitHub runners).

## Quick Start

## 1) Fork the repository

1. Open the original repo:
   `https://github.com/mkpromvp/Stock-rom-dumber`
2. Click **Fork**.
3. Choose your account.
4. Open your forked repository.

## 2) Verify workflow file

Main workflow path:
`.github/workflows/main.yml`

If you use a custom version, replace this file fully with your final workflow.

## 3) Add repository secrets (if needed)

1. Open:
   `Settings -> Secrets and variables -> Actions`
2. Click:
   `New repository secret`
3. Add required secrets exactly as documented below.

## 4) Run the workflow

1. Open:
   `Actions`
2. Select workflow:
   `HyperOS ROM Dumper (DumprX -> Multi Upload)`
3. Click:
   `Run workflow`
4. Fill input fields and run.

## 5) Check results

- If `upload_github_branch=true`, output is pushed to a smart branch in the same repo.
- If external uploads are enabled, the same dump is uploaded there too.

---

## Workflow Inputs Explained

- `rom_url`:
  Direct ROM link. Must start with `http://` or `https://`.
- `target_branch`:
  Manual branch name. Use `auto` for smart naming.
- `device_name`:
  Fallback codename if detection fails.
- `extract_contents`:
  `true/false` to extract image filesystem contents.
- `compress_images`:
  `true/false` to compress `.img` files.
- `upload_github_branch`:
  `true/false` to enable or disable upload to this repo smart branch.
- `upload_gitlab`:
  `true/false` to enable GitLab upload.
- `upload_gitea`:
  `true/false` to enable Gitea/Codeberg upload.
- `upload_sourceforge`:
  `true/false` to enable SourceForge upload.
- `upload_r2`:
  `true/false` to enable Cloudflare R2 upload.

---

## Smart Branch Naming

When `target_branch=auto`, workflow tries to read from dumped `README.md`:

- Brand
- Codename
- Incremental

Then creates:

`dump-brand-codename-incremental`

Rules:
- Name is sanitized automatically.
- `main` is never used.
- Fallback pattern if needed:
  `dumps-YYYYMMDD-HHMMSS`

---

## Upload Methods (Detailed)

## 1) GitHub Branch Upload (same repository)

Enabled when:
`upload_github_branch=true`

Needs:
- No extra secret.
- Uses built-in `GITHUB_TOKEN`.

What it does:
- Creates or updates smart branch.
- Copies dump output to repo root.
- Applies LFS tracking for large files.
- Commits and pushes with retry logic.

When to disable:
- You do not want dump files in this repository.
- You only want external upload targets.

---

## 2) GitLab Upload

Enabled when:
`upload_gitlab=true`

Required secrets:
- `GITLAB_TOKEN`
- `GITLAB_USERNAME`
- `GITLAB_REPO`

Recommended token scope:
- `write_repository`

Remote format used:
`https://GITLAB_USERNAME:GITLAB_TOKEN@gitlab.com/GITLAB_USERNAME/GITLAB_REPO.git`

Setup steps:
1. Create project on GitLab.
2. Create Personal Access Token.
3. Grant `write_repository`.
4. Add secrets in GitHub repo.
5. Run workflow with `upload_gitlab=true`.

---

## 3) Gitea / Codeberg Upload

Enabled when:
`upload_gitea=true`

Required secrets:
- `GITEA_TOKEN`
- `GITEA_USERNAME`
- `GITEA_REPO`
- `GITEA_URL` (example: `https://codeberg.org`)

Setup steps:
1. Create repo on Gitea or Codeberg.
2. Generate access token with write/push permissions.
3. Add required secrets.
4. Run workflow with `upload_gitea=true`.

Notes:
- `GITEA_REPO` should be repo name only.
- Username is provided by `GITEA_USERNAME`.

---

## 4) SourceForge Upload

Enabled when:
`upload_sourceforge=true`

Required secrets:
- `SF_USER`
- `SF_PROJECT`
- `SF_SSH_KEY` (private key)

Upload path:
`/home/frs/project/SF_PROJECT/BRANCH/`

Setup steps:
1. Create SourceForge project.
2. Add your SSH public key to SourceForge account.
3. Save matching private key in `SF_SSH_KEY`.
4. Run with `upload_sourceforge=true`.

Security advice:
- Use a dedicated SSH key for automation.
- Do not reuse your primary personal key.

---

## 5) Cloudflare R2 Upload

Enabled when:
`upload_r2=true`

Required secrets:
- `R2_ACCESS_KEY_ID`
- `R2_SECRET_ACCESS_KEY`
- `R2_BUCKET`
- `R2_ENDPOINT`

Setup steps:
1. Create R2 bucket in Cloudflare.
2. Create R2 API credentials.
3. Copy endpoint URL for your account.
4. Add all four secrets.
5. Run with `upload_r2=true`.

Upload target format:
`s3://R2_BUCKET/BRANCH/`

---

## Example Run

Example configuration:

- `rom_url`: direct ROM URL
- `target_branch`: `auto`
- `device_name`: `spes`
- `extract_contents`: `true`
- `compress_images`: `false`
- `upload_github_branch`: `false`
- `upload_gitlab`: `true`
- `upload_gitea`: `false`
- `upload_sourceforge`: `false`
- `upload_r2`: `true`

Expected result:
- No upload to GitHub branch.
- Upload to GitLab and R2 using the same smart branch name.

---

## Behavior When Secrets Are Missing

- Each external upload step validates required secrets.
- If a secret is missing:
  - That specific upload step is skipped.
  - Workflow continues for other enabled targets.

---

## Important Output Files

- `_dump_info.txt`:
  Run metadata and upload status.
- `file_list.txt`:
  Sorted list of files.
- `*.sha256`:
  Checksum files.
- `extracted/`:
  Present if `extract_contents=true`.

---

## Troubleshooting

- `rom_url is empty`:
  Provide a valid URL input.
- `rom_url must start with http/https`:
  Fix link format.
- Wrong or unexpected branch name:
  Set `target_branch` manually.
- External push failed:
  Re-check token, repo name, username, URL, permissions.
- SourceForge failed:
  Verify SSH key pair and account key registration.

---

## Best Practices

- First run with only GitHub upload enabled.
- Then enable one external destination at a time.
- Use separate tokens per platform.
- Never hardcode secrets in workflow file.
- Rotate tokens periodically.

---

## Contributing

1. Fork repository.
2. Create feature branch.
3. Commit your changes.
4. Open Pull Request.

---

## Credits

- [DumprX](https://github.com/DumprX/DumprX) for core dumping engine.
- GitHub Actions ecosystem and community tooling.
- Maintained by mkpromvp and contributors.
