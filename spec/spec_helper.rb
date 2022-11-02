# frozen_string_literal: true

ROOT = Pathname.new(File.expand_path('..', __dir__))
$LOAD_PATH.unshift("#{ROOT}lib".to_s, "#{ROOT}spec".to_s)

require 'danger'
require 'pry'
require 'rspec'
require 'simplecov'
SimpleCov.start do
  load_profile 'test_frameworks'
  enable_coverage :branch
end
require 'danger_plugin'
require 'support/helpers'

RSpec.configure do |config|
  config.filter_gems_from_backtrace 'bundler'
  config.include FixtureHelper
  config.include XcodeHelper
end
