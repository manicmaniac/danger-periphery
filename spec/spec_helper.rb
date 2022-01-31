# frozen_string_literal: true

ROOT = Pathname.new(File.expand_path("..", __dir__))
$:.unshift("#{ROOT}lib".to_s, "#{ROOT}spec".to_s)

require "bundler/setup"
require "periphery"
require "pry"
require "rspec"

RSpec.configure do |config|
  config.filter_gems_from_backtrace "bundler"
end

def fixtures_path
  Pathname.new("../support/fixtures").expand_path(__FILE__)
end

def fixture(filename)
  fixtures_path.join(filename).to_s
end

def binaries_path
  Pathname.new("../../bin").expand_path(__FILE__)
end

def binary(filename)
  binaries_path.join(filename).to_s
end
