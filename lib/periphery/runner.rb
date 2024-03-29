# frozen_string_literal: true

require 'open3'
require 'rubygems/version'

module Periphery
  class Runner # :nodoc:
    attr_reader :binary_path

    def initialize(binary_path)
      @binary_path = binary_path || 'periphery'
    end

    def scan(options)
      arguments = [binary_path, 'scan'] + scan_arguments(options)
      stdout, stderr, status = Open3.capture3(*arguments)
      raise "error: #{arguments} exited with status code #{status.exitstatus}. #{stderr}" unless status.success?

      stdout
    end

    def scan_arguments(options)
      options.each_with_object([]) do |(key, value), new_options|
        next unless value

        value = nil if value.is_a?(TrueClass)
        if value.is_a?(Array)
          if Gem::Version.new(version) >= Gem::Version.new('2.18.0')
            new_options << "--#{key.to_s.tr('_', '-')}"
            new_options.push(*value.map(&:to_s))
            next
          else
            value = value.join(',')
          end
        end
        new_options << "--#{key.to_s.tr('_', '-')}"
        new_options << value&.to_s if value
      end
    end

    def version
      arguments = [binary_path, 'version']
      stdout, stderr, status = Open3.capture3(*arguments)
      raise "error: #{arguments} existed with status code #{status.exitstatus}. #{stderr}" unless status.success?

      stdout.strip
    end
  end
end
