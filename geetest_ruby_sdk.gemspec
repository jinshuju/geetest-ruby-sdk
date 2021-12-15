require_relative 'lib/geetest_ruby_sdk/version'

Gem::Specification.new do |spec|
  spec.name = 'geetest_ruby_sdk'
  spec.version = GeetestRubySdk::VERSION
  spec.authors = ['Yuehao Hua']
  spec.email = ['huayuehao@jinshuju.net']

  spec.summary = 'Ruby version of Geetest SDK'
  spec.homepage = 'https://github.com/jinshuju/geetest-ruby-sdk'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'https://github.com/jinshuju/geetest-ruby-sdk'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jinshuju/geetest-ruby-sdk'
  spec.metadata['changelog_uri'] = 'https://github.com/jinshuju/geetest-ruby-sdk'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
