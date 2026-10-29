require_relative "../lib/synergy3_download_strategy"

cask "synergy3" do
  arch arm: "arm64", intel: "x64"

  version "3.9.1"
  sha256 arm:   "c4f0d880d79b108c7e08fcef6c6bc17443229e2f90b2e1d1b803c3f60e0a5c56",
         intel: "d219c9afe62425602d40feb63ffaab79a31700362e5bb73d745908e341c695ce"

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
