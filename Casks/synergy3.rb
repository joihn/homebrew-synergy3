require_relative "../lib/synergy3_download_strategy"

cask "synergy3" do
  arch arm: "arm64", intel: "x64"

  version "3.6.3"
  sha256 arm:   "8fb39b09a0354ab29878f8eb96aa32b815ed897cc7ea23da26150e55f5aa2321",
         intel: "5b51490936f893fca4e88995a8c95e98cda44606feb71291cafc83b6633d61d2"

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
