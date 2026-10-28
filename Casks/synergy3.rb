require_relative "../lib/synergy3_download_strategy"

cask "synergy3" do
  arch arm: "arm64", intel: "x64"

  version "3.9.0"
  sha256 arm:   "a87d184bb78267c28e70e5ed72d73a353e481b7e278a04d941eb543a072a05c5",
         intel: "ba5294c93c2a0d2c4e4e37e409b88573b675aba095f6929eb66579bfdc3fbe6f"

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
