# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:specs)
Rake.application.lookup(:specs).enhance(%I[periphery:install])

task default: :specs

task spec: %i[specs rubocop spec_docs]

desc 'Run RuboCop on the lib/specs directory'
RuboCop::RakeTask.new(:rubocop)

desc 'Ensure that the plugin passes `danger plugins lint`'
task :spec_docs do
  sh 'danger plugins lint'
end

namespace :periphery do
  desc 'Download and install Periphery executable'
  task install: 'bin/periphery'
end

# Keep the next line for renovate.
# @see renovate.json
PERIPHERY_VERSION = '2.10.0'

file 'bin/periphery' do |f|
  require 'periphery/installer'

  Periphery::Installer.new(PERIPHERY_VERSION).install(f.name, force: true)
end
