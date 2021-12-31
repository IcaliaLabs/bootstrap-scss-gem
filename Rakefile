# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :bootstrap do
  desc 'Fetch the required bootstrap vendored code'
  task :test do
    require 'rugged'
    this_path = File.expand_path __dir__
    this_repo = Rugged::Repository.new this_path
    bootstrap_submodule = this_repo.submodules.detect do |submodule|
      submodule.url.match? 'github.com/twbs/bootstrap'
    end

    bootstrap_commit = bootstrap_submodule.head_oid

    require 'addressable/uri'
    bootstrap_github_repo_name = (
      uri = Addressable::URI.parse(bootstrap_submodule.url)
    ).omit(:query, :fragment).path[1..].gsub Regexp.new("#{uri.extname}\\z"), ''

    require 'octokit'
    github = Octokit::Client.new
    release_major_version = '5'
    bootstrap_release = github.releases(bootstrap_github_repo_name).detect do |rel|
      rel.tag_name.start_with? "v#{release_major_version}"
    end

    bootstrap_tag = bootstrap_release.tag_name
    bootstrap_repo = bootstrap_submodule.repository
    bootstrap_repo.fetch 'origin'
    bootstrap_repo.checkout bootstrap_tag
  end
end
