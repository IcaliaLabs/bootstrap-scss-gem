# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bootstrap/scss/version'

Gem::Specification.new do |spec|
  spec.name          = 'bootstrap-scss'
  spec.version       = Bootstrap::Scss::VERSION
  spec.authors       = ['Roberto Quintanilla']
  spec.email         = ['roberto.quintanilla@gmail.com']

  spec.summary       = 'Bundle Bootstrap SCSS without requiring npm'
  spec.description   = 'Bundle Bootstrap SCSS without requiring npm'
  spec.homepage      = 'https://github.com/IcaliaLabs/bootstrap-scss-gem'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/IcaliaLabs/bootstrap-scss-gem'
    spec.metadata['changelog_uri'] = 'https://github.com/IcaliaLabs/bootstrap-scss-gem/blob/main/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  files = 'lib/* *.md *.gemspec *.txt vendor/assets/bootstrap/scss/*'

  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.files         = `git ls-files --recurse-submodules -- #{files}`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.bindir        = 'exe'
  spec.require_paths = ['lib']

  # SassC requires Ruby 2.3.3. Also specify here to make it obvious.
  spec.required_ruby_version = '>= 2.3.3'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rugged', '~> 1.3'
  spec.add_development_dependency 'octokit', '~> 4.21'
end
