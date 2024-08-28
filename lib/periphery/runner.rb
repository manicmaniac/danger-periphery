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

      if options[:build_args]
        arguments << "--"
        arguments += Array(options[:build_args])
      end

      stdout, stderr, status = Open3.capture3(*arguments)
      raise "error: #{arguments} exited with status code #{status.exitstatus}. #{stderr}" unless status.success?

      stdout
    end

    def scan_arguments(options)
      args = []

      options.each do |key, value|
        next unless value

        next if key == :build_args

        value = nil if value.is_a?(TrueClass)
        if value.is_a?(Array)
          if Gem::Version.new(version) >= Gem::Version.new('2.18.0')
            args << "--#{key.to_s.tr('_', '-')}"
            args.push(*value.map(&:to_s))
          else
            args << "--#{key.to_s.tr('_', '-')}"
            args << value.join(',')
          end
        else
          args << "--#{key.to_s.tr('_', '-')}"
          args << value&.to_s if value
        end
      end

      args
    end

    def version
      arguments = [binary_path, 'version']
      stdout, stderr, status = Open3.capture3(*arguments)
      raise "error: #{arguments} existed with status code #{status.exitstatus}. #{stderr}" unless status.success?

      stdout.strip
    end
  end
end
