# frozen_string_literal: true

require "open3"

module Periphery
  class Runner
    attr_reader :binary_path

    def initialize(binary_path)
      @binary_path = binary_path || "periphery"
    end

    def scan(options)
      arguments = [binary_path, "scan"] + scan_arguments(options)
      stdout, stderr, status = Open3.capture3(*arguments)
      if status.success?
        stdout
      else
        raise "error: #{arguments} exited with status code #{status.exitstatus}. #{stderr}" unless status.success?
      end
    end

    def scan_arguments(options)
      options.
        lazy.
        select { |_key, value| value }.
        map { |key, value| value.kind_of?(TrueClass) ? [key, nil] : [key, value] }.
        map { |key, value| value.kind_of?(Array) ? [key, value.join(",")] : [key, value] }.
        map { |key, value| ["--#{key.to_s.tr('_', '-')}", value] }.
        force.
        flatten.
        compact
    end
  end
end
