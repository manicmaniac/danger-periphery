# frozen_string_literal: true

ROOT = File.expand_path('..', __dir__)
$LOAD_PATH.unshift(File.join(ROOT, 'lib'), File.join(ROOT, 'spec'))

require 'danger'
require 'pry'
require 'rspec'
require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config do |config|
  config.report_with_single_file = true
  config.output_directory = 'coverage'
  config.lcov_file_name = 'lcov.info'
end
SimpleCov.start do
  load_profile 'test_frameworks'
  enable_coverage :branch
  formatter SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::LcovFormatter,
                                                      SimpleCov::Formatter::HTMLFormatter])
end
require 'danger_plugin'
require 'support/helpers'
require 'support/shared_examples'

RSpec.configure do |config|
  config.filter_gems_from_backtrace 'bundler'
  config.include FixtureHelper
end
