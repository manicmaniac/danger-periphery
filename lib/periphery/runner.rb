# frozen_string_literal: true

require 'open3'

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
        value = value.join(',') if value.is_a?(Array)
        new_options << "--#{key.to_s.tr('_', '-')}"
        new_options << value&.to_s if value
      end
    end
  end
end
