# sdenike/homebrew-tap

Homebrew tap for my macOS applications. One tap, every app — rather than a separate
tap repository per application.

## Install

```sh
brew tap sdenike/tap
```

Then install whichever apps you want:

```sh
brew install --cask textmate-revived
brew install --cask hidden-revived
brew install sdenike/tap/ffmpeg
```

You only need to run `brew tap` once. Anything added to this tap later is available
immediately with `brew install --cask <name>` (apps) or `brew install sdenike/tap/<name>`
(formulae).

## Available casks

| Cask | Application | Requirements |
|---|---|---|
| `textmate-revived` | [TextMate Revived](https://github.com/sdenike/textmate) — maintained fork of TextMate | macOS 26+, Apple silicon |
| `hidden-revived` | [Hidden Bar Revived](https://github.com/sdenike/hidden-revived) — hides menu bar items | macOS 13+ |

Every app is signed with a Developer ID certificate and notarized by Apple, so it
installs and launches without Gatekeeper warnings.

## Available formulae

| Formula | Description | Requirements |
|---|---|---|
| `ffmpeg` | [FFmpeg](https://ffmpeg.org/) 9.0.2 with every codec and filter, built for Apple silicon — see below | macOS, Apple silicon |

### ffmpeg

A source-build drop-in replacement for homebrew-core's `ffmpeg`: same keg layout, same
revision and `compatibility_version`, so packages that link FFmpeg (mpv, etc.) keep working.
Compared with core it adds:

- Apple silicon tuning (`-mcpu=apple-m1`; NEON, DOTPROD, I8MM, SVE/SVE2 with runtime detection)
- VideoToolbox, AudioToolbox and Metal support
- Extra codecs and filters: libfdk-aac, whisper (with canonical JSON output), VVenC, JPEG XL,
  AOM, SVT-AV1, dav1d, libvmaf, SRT, libbluray, OpenJPEG, Theora, Vorbis, WebP, drawtext/libass
- Patched `yadif_videotoolbox` (teardown crash fix, FFmpeg PR 23850)
- `ffplay`, all extra tools (`zmqsend`, etc.) and `ffmpeg-info` — run `ffmpeg-info --all` to
  list everything compiled in

```sh
brew install sdenike/tap/ffmpeg
```

Always use the full name `sdenike/tap/ffmpeg`; the bare name resolves to homebrew-core's.
`brew info ffmpeg` will warn that this tap shadows core — that is expected. If core's
`ffmpeg` gets pulled in by another install, fix it with:

```sh
brew uninstall --ignore-dependencies ffmpeg && brew install sdenike/tap/ffmpeg
```

**Nonfree:** this build links libfdk-aac, so the binaries must not be redistributed. The
formula builds from source only and ships no bottles; expect a long first build.

Hardware encode needs `-c:v h264_videotoolbox` / `hevc_videotoolbox`; hardware decode needs
`-hwaccel videotoolbox`. libx264/libx265 are CPU-only.

## Updating

```sh
brew update && brew upgrade --cask
```

Formulae are not auto-bumped: check `brew livecheck sdenike/tap/ffmpeg`, then reinstall with
`brew reinstall --build-from-source sdenike/tap/ffmpeg`.

`textmate-revived` is marked `auto_updates true` because the app updates itself from
GitHub Releases. Homebrew will install it and then step out of the way rather than
fighting the built-in updater.

## How casks here stay current

Cask versions and checksums are **not** maintained by hand. Each application's release
workflow, on publishing a GitHub Release, computes the asset's SHA-256 and opens a pull
request against this repository updating that app's cask. See
`.github/workflows/` in the application repositories.

## Uninstalling

```sh
brew uninstall --cask <name>
```

Add `--zap` to also remove preferences, caches and application-support files:

```sh
brew uninstall --zap --cask textmate-revived
```

## History

`hidden-revived` previously lived in its own tap, `sdenike/homebrew-hidden-revived`.
It moved here in August 2026 so that a single `brew tap` serves every application.
