#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "open3"
require "tempfile"
require "uri"

PRODUCT_PAGE = "https://symless.com/synergy/download/synergy3-personal"
PACKAGE_ROOT = "https://symless.com/synergy/download/package/synergy-personal-v3"
API_ROOT = "https://symless.com/synergy/api/download"
CASK_PATH = File.expand_path("../Casks/synergy3.rb", __dir__)
ARCHITECTURES = %w[arm64 x64].freeze

def curl(*arguments)
  stdout, stderr, status = Open3.capture3(
    "curl", "--fail", "--location", "--silent", "--show-error", *arguments
  )
  raise "curl failed: #{stderr.strip}" unless status.success?

  stdout
end

def latest_packages
  page = curl(PRODUCT_PAGE)
  version = page[/versionNumber[^>]*>v?(\d+(?:\.\d+)+)</i, 1]
  raise "Could not find the latest Synergy version" if version.nil?

  packages = {}
  ARCHITECTURES.each do |architecture|
    filename = "synergy-#{version}-macos-#{architecture}.dmg"
    match = page.match(
      /\\"fileName\\":\\"#{Regexp.escape(filename)}\\".{0,1000}?\\"productPackageOs\\":\{.*?\\"slug\\":\\"([^"\\]+)\\"/
    )
    raise "Could not find package metadata for #{filename}" if match.nil?

    packages[architecture] = { filename: filename, slug: match[1] }
  end

  slugs = packages.values.map { |package| package.fetch(:slug) }.uniq
  raise "macOS packages use different platform slugs: #{slugs.join(", ")}" unless slugs.one?

  [version, packages]
end

def checksum(package)
  filename = package.fetch(:filename)
  cache_dir = ENV["SYNERGY_ARTIFACT_CACHE"]
  cached_path = File.join(cache_dir, filename) if cache_dir
  return Digest::SHA256.file(cached_path).hexdigest if cached_path && File.file?(cached_path)

  package_page = "#{PACKAGE_ROOT}/#{package.fetch(:slug)}/#{filename}"
  page = curl(package_page)
  token = page[/\\"token\\":\\"([^"\\]+)\\"/, 1]
  raise "Could not find a guest download token for #{filename}" if token.nil?

  Tempfile.create([filename, ".download"]) do |file|
    file.close
    puts "Downloading #{filename}..."
    curl("--output", file.path, "#{API_ROOT}/#{filename}?token=#{URI.encode_www_form_component(token)}")
    Digest::SHA256.file(file.path).hexdigest
  end
end

version, packages = latest_packages
cask = File.read(CASK_PATH)
current_version = cask[/^[ \t]*version "([^"]+)"/, 1]
force = ARGV.delete("--force")
abort "Usage: #{File.basename($PROGRAM_NAME)} [--force]" unless ARGV.empty?

if current_version == version && !force
  puts "Synergy #{version} is already current."
  exit
end

hashes = packages.transform_values { |package| checksum(package) }
slug = packages.fetch("arm64").fetch(:slug)

updated = cask.sub(/^[ \t]*version "[^"]+"/, "  version \"#{version}\"")
updated.sub!(
  /^[ \t]*sha256 arm:[ \t]+"[0-9a-f]{64}",\n[ \t]+intel:[ \t]+"[0-9a-f]{64}"/,
  %(  sha256 arm:   "#{hashes.fetch("arm64")}",\n         intel: "#{hashes.fetch("x64")}")
)
updated.sub!(
  %r{synergy-personal-v3/[^/]+/" \\\n},
  "synergy-personal-v3/#{slug}/\" \\\n"
)

raise "Failed to update the cask" if updated == cask

File.write(CASK_PATH, updated)
puts "Updated Synergy #{current_version} -> #{version}."
