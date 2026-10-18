require_relative "../lib/synergy3_download_strategy"

cask "synergy3" do
  arch arm: "arm64", intel: "x64"

  version "3.8.4"
  sha256 arm:   "df5fd65cc8f37945fbda7efa26511c787dbf21a8f108ddffc562af0366ff1097",
         intel: "eb6c89ac2ce9c88d3cdc820e06e0a44d404f2c676d6fbafa661471a5ce21fdc9"

  url "https://symless.com/synergy/download/package/synergy-personal-v3/macos-12.0/synergy-#{version}-" \
      "macos-#{arch}.dmg",
      using: Synergy3DownloadStrategy
  name "Synergy 3"
  desc "Share one keyboard and mouse across multiple computers"
  homepage "https://symless.com/synergy"

  livecheck do
    url "https://symless.com/synergy/download/synergy3-personal"
    regex(/fileName.*?synergy[._-]v?(\d+(?:\.\d+)+)[._-]macos[._-](?:arm64|x64)\.dmg/i)
    strategy :page_match
  end

  depends_on macos: :monterey

  app "Synergy.app"

  uninstall quit: "com.symless.synergy"

  zap trash: "~/Library/Preferences/synergy"
end
