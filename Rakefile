# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :bootstrap do
  desc 'Fetch the required bootstrap vendored code'
  task fetch: :environment do
    require 'zlib'
    require 'debug'
    require 'faraday'
    require 'rubygems/package'
    require 'faraday_middleware'
    require 'bootstrap/scss/version'

    base_url = 'https://github.com/twbs/bootstrap/archive/refs/tags'
    download_url = "#{base_url}/v#{Bootstrap::Scss::VERSION}.tar.gz"

    connection = Faraday.new do |conn|
      conn.use FaradayMiddleware::FollowRedirects
    end

    io = StringIO.new(response = connection.get download_url)&.body
    gz = Zlib::GzipReader.new io
    tar = Gem::Package::TarReader.new gz

    src_dir = "bootstrap-#{Bootstrap::Scss::VERSION}"
    scss_dir = "#{src_dir}/scss"

    target_dir = Pathname.new(__dir__).join('vendor', 'assets', 'stylesheets', 'bootstrap')
    target_dir.rmtree if target_dir.exist?
    target_dir.mkpath

    tar.each do |entry|
      next unless entry.full_name.match?(scss_dir) && entry.file?

      (target_path = Pathname.new entry.full_name.gsub src_dir, target_dir.to_s)
        .parent
        .mkpath

      target_path.write entry.read
    end
  end
end
