# Homebrew Synergy tap

This tap installs the current Synergy 3 personal macOS app. Symless offers
guest downloads, but the final CDN URL is short-lived. The tap exchanges the
public guest token during each download and still verifies the DMG with a
release-specific SHA-256 checksum.

## Install

```sh
brew tap joihn/synergy3
brew install --cask joihn/synergy3/synergy3
```

Normal Homebrew updates then work as expected:

```sh
brew update
brew upgrade --cask joihn/synergy3/synergy3
```

The scheduled GitHub Actions workflow checks for a new release each day. On a
new release it downloads both macOS builds, updates the version and checksums,
and commits the cask change. The next `brew update` fetches that commit, and
`brew upgrade` installs it. The tap does not run background upgrades on users'
Macs.

## Update locally

```sh
ruby script/update.rb
```

The optional `SYNERGY_ARTIFACT_CACHE` environment variable may point to a
directory containing already-downloaded DMGs named exactly as Symless names
them.

## Notes

- The cask supports Apple Silicon and Intel Macs running macOS 12 or newer.
- Synergy still requires a valid license when the app starts.
- The `synergy-core` formula in Homebrew is the open-source core/CLI build; it
  is not the same package as this Synergy 3 desktop distribution.
