# 2-Stroke.Guru

2-Stroke.Guru is an offline-ready SwiftUI handbook for 2-stroke engine repair. It organizes researched repair guidance into book-style categories for fundamentals, diagnostics, fuel and air, top-end work, and reference material.

The iOS app loads bundled seed content, checks the Vercel-hosted static content manifest, verifies the downloaded bundle with SHA-256, and caches the latest verified content on device.

## Author

Leven Sailor

## Project Structure

- `data/content.json` is the shared content source for the app and static backend.
- `scripts/export-content.mjs` writes `/content/manifest.json` and `/content/content.json` for Vercel.
- `ios/TwoStrokeGuru/` contains the SwiftUI iOS app.
- `public/index.html` is a small landing page for the content backend.

## Deployment

The repository is linked to Vercel. Push changes to the main branch and Vercel will run:

```sh
npm run build
```

That command exports the static content API into `public/content/`.

## Public Assets

- Content manifest: `https://4x4.vercel.app/content/manifest.json`
- Content bundle: `https://4x4.vercel.app/content/content.json`
- Landing page: `https://4x4.vercel.app/`

No login is required for the public content endpoints.

## iOS App

Open `ios/TwoStrokeGuru/TwoStrokeGuru.xcodeproj` in Xcode. The app display name is `2-Stroke.Guru`, and the remote content base URL is configured through the `ContentBaseURL` Info.plist key.
