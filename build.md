# Build and Release Checklist

This project publishes Android APK releases from GitHub Actions using `.github/workflows/flutter-apk.yml`.

## One-time setup

- [ ] Repository secret `ANILIST_CLIENT_ID` is added in GitHub:
  - `Settings` -> `Secrets and variables` -> `Actions` -> `New repository secret`
- [ ] You have push access to `main` and tags.
- [ ] Local branch is up to date:

```powershell
git checkout main
git pull origin main
```

## Per-release checklist

- [ ] Choose next app version (example: `0.0.3`).
- [ ] Update `app/pubspec.yaml` `version:` to `X.Y.Z+BUILD` (example: `0.0.3+5`).
- [ ] Commit and push the version change.
- [ ] Create and push git tag `vX.Y.Z` (must match `pubspec` version exactly).
- [ ] Confirm GitHub Action passed.
- [ ] Confirm GitHub Release is created with APK attached.

## Commands (tag-triggered release, recommended)

```powershell
# 1) Update local main
git checkout main
git pull origin main

# 2) Edit app/pubspec.yaml:
# version: 0.0.3+5

# 3) Commit and push version bump
git add app/pubspec.yaml app/pubspec.lock
git commit -m "chore(release): bump version to 0.0.3+5"
git push origin main

# 4) Create release tag (must match pubspec version: v0.0.3)
git tag v0.0.3
git push origin v0.0.3
```

Result:
- GitHub Action `Flutter Release APK` runs automatically.
- A release named `v0.0.3` is created.
- `app-release.apk` is uploaded to that release.

## Manual release run (workflow_dispatch)

Use this only when needed.

Requirements:
- `app/pubspec.yaml` version must already be `X.Y.Z+BUILD`.
- Input `tag_name` must be exactly `vX.Y.Z`.

Steps:
1. Open `Actions` -> `Flutter Release APK` -> `Run workflow`.
2. Enter `tag_name` (example: `v0.0.3`).
3. Run workflow on `main`.

## Validation and troubleshooting

If action fails with tag/version mismatch:
- Ensure `app/pubspec.yaml` is `version: 0.0.3+...`
- Ensure release tag is exactly `v0.0.3`

If action fails at `flutter pub get --enforce-lockfile`:

```powershell
cd app
flutter pub get
cd ..
git add app/pubspec.lock
git commit -m "chore(lockfile): sync pubspec.lock"
git push origin main
```

If release is not created:
- Check workflow logs for `Prepare release metadata` and `Publish GitHub release asset`.
- Confirm `GITHUB_TOKEN` has `contents: write` (already set in workflow).
