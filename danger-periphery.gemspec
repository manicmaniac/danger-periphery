# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name = 'danger-periphery'
  spec.version = DangerPeriphery::VERSION
  spec.authors = ['Ryosuke Ito']
  spec.email = ['rito.0305@gmail.com']
  spec.description = 'A Danger plugin to detect unused codes.'
  spec.summary = spec.description
  spec.homepage = 'https://github.com/manicmaniac/danger-periphery'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'danger-plugin-api', '~> 1.0'
  spec.add_dependency 'rubyzip', '~> 2.0'
end
