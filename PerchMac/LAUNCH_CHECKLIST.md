# PerchMac — Launch Checklist

## Pre-Launch

### Code & Build
- [ ] All Swift files compile without warnings
- [ ] Build succeeds: `xcodebuild -scheme PerchMac -configuration Release`
- [ ] No hardcoded colors — all colors via `Theme.swift` tokens ✅ audited R13
- [ ] No placeholder strings in UI
- [ ] App icon set present in Assets.xcassets

### Entitlements & Capabilities
- [ ] App Sandbox: Enabled
- [ ] Hardened Runtime: Enabled
- [ ] Network access (if applicable): Signed with capability

### Code Signing
- [ ] Development Team set in project
- [ ] Release build: `CODE_SIGN_IDENTITY` configured
- [ ] Provisioning profile valid for distribution

---

## App Store Connect

### Metadata
- [ ] App name: **PerchMac**
- [ ] Tagline: **"Bird smarter, spot more."**
- [ ] Category: Reference > Nature & Wildlife
- [ ] Age rating: 4+
- [ ] Description written and reviewed
- [ ] Keywords configured
- [ ] Support URL set
- [ ] Privacy Policy URL set
- [ ] Screenshots uploaded (1280×800, 5 screenshots)

### Content
- [ ] No placeholder/incomplete content
- [ ] No debug UI or developer-only screens
- [ ] All copy grammatically correct

---

## Build & Upload

### Archive
- [ ] Scheme: PerchMac
- [ ] Configuration: **Release**
- [ ] Destination: macOS (arm64 + x86_64 if needed)
- [ ] Code signed for distribution
- [ ] Archive created in Xcode

### Upload
- [ ] Valid provisioning profile for distribution
- [ ] Uploaded via Xcode > Product > Archive > Distribute
- [ ] Build appears in App Store Connect (Activity tab)

---

## Post-Upload Review

- [ ] Build status: "Processing" → "Ready to Submit"
- [ ] Manually release or set automatic release date
- [ ] Notify team of launch
- [ ] Monitor App Store Connect for rejection issues

---

## External

- [ ] Website/social media assets ready
- [ ] Support channel monitored (email/contact)
- [ ] Analytics / crash reporting active

---

## Version History

| Version | Date | Notes |
|---------|------|-------|
| 1.0.0 | — | Initial release |
| R13 | 2026-03-29 | Polish pass: App Store listing, dark mode audit, launch checklist |
