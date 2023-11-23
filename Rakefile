# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new
Rake.application.lookup(:spec).enhance(%I[periphery:install])

RuboCop::RakeTask.new(:rubocop)

task default: :spec

desc 'Run all linters'
task lint: %I[rubocop lint_docs]

desc 'Ensure that the plugin passes `danger plugins lint`'
task :lint_docs do
  sh 'danger plugins lint'
end

namespace :periphery do
  desc 'Download and install Periphery executable'
  task install: 'bin/periphery'
end

# Keep the next line for renovate.
# @see renovate.json
PERIPHERY_VERSION = '2.17.0'

file 'bin/periphery' do |f|
  require 'periphery/installer'

  Periphery::Installer.new(PERIPHERY_VERSION).install(f.name, force: true)
end
