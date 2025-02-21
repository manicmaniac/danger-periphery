# frozen_string_literal: true

require_relative 'lib/danger_periphery/version'

Gem::Specification.new do |spec|
  spec.name = 'danger-periphery'
  spec.version = DangerPeriphery::VERSION
  spec.authors = ['Ryosuke Ito']
  spec.email = ['rito.0305@gmail.com']
  spec.summary = 'A Danger plugin to detect unused codes.'
  spec.description = <<~DESC
    This project is a plugin for Danger, which is a tool for monitoring the quality of the codebase.
    This plugin detects unused codes in your Swift project using Periphery.
  DESC
  spec.homepage = 'https://github.com/manicmaniac/danger-periphery'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'
  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/manicmaniac/danger-periphery/issues',
    'changelog_uri' => 'https://raw.githubusercontent.com/manicmaniac/danger-periphery/refs/heads/master/CHANGELOG.md',
    'documentation_uri' => "https://www.rubydoc.info/gems/danger-periphery/#{spec.version}",
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'danger-plugin-api', '~> 1.0'
  spec.add_dependency 'rubyzip', '~> 2.0'
end
