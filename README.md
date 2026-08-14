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
```

You only need to run `brew tap` once. Anything added to this tap later is available
immediately with `brew install --cask <name>`.

## Available casks

| Cask | Application | Requirements |
|---|---|---|
| `textmate-revived` | [TextMate Revived](https://github.com/sdenike/textmate) — maintained fork of TextMate | macOS 26+, Apple silicon |
| `hidden-revived` | [Hidden Bar Revived](https://github.com/sdenike/hidden-revived) — hides menu bar items | macOS 13+ |

Every app is signed with a Developer ID certificate and notarized by Apple, so it
installs and launches without Gatekeeper warnings.

## Updating

```sh
brew update && brew upgrade --cask
```

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
