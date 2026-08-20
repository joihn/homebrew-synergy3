# frozen_string_literal: true

require "download_strategy"
require "uri"

# Synergy's public download page creates a short-lived guest token before
# redirecting to its CDN. This strategy performs that public token exchange so
# Homebrew can download the versioned DMG declared by the cask.
class Synergy3DownloadStrategy < CurlDownloadStrategy
  PACKAGE_PATH_PREFIX = "/synergy/download/package/synergy-personal-v3/"

  private

  def resolve_url_basename_time_file_size(url, timeout: nil)
    uri = URI(url)
    return super unless uri.host == "symless.com" && uri.path.start_with?(PACKAGE_PATH_PREFIX)

    @synergy_resolved_url ||= begin
      result = curl_output("--fail", "--location", "--silent", "--show-error", url, timeout: timeout)
      unless result.success?
        raise CurlDownloadStrategyError.new(url, result.stderr.strip)
      end

      page = result.stdout
      token = page[/\\"token\\":\\"([^"\\]+)\\"/, 1]
      raise CurlDownloadStrategyError.new(url, "Could not find Synergy guest download token") if token.nil?

      filename = File.basename(uri.path)
      api_url = "https://symless.com/synergy/api/download/#{filename}?token=#{token}"

      [api_url, filename, nil, nil, "application/octet-stream", true]
    end
  end
end
