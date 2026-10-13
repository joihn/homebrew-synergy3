require_relative "../lib/synergy3_download_strategy"

cask "synergy3" do
  arch arm: "arm64", intel: "x64"

  version "3.8.2"
  sha256 arm:   "14ee1e56f5f0926fb4d416c5e439d42e2ee5acd463329f51409983f0a0edec8f",
         intel: "8e220df77528aaaeb67917eb14e96c0f2304ae9ba46b214de9ad56245579e355"

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
