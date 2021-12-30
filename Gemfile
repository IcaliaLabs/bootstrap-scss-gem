# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in bootstrap-scss.gemspec
gemspec

group :development do
  gem 'reek', '~> 6.0', '>= 6.0.2', require: false

  gem 'rubocop',             '~> 1.24', require: false
  gem 'rubocop-performance', '~> 1.13', require: false
  gem 'rubocop-rspec',       '~> 2.6',  require: false

  # IDE tools for code completion, inline documentation, and static analysis
  gem 'solargraph', '~> 0.44.2', require: false
end
