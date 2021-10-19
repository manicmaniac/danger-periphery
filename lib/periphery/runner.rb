require "open3"

module Periphery
  class Runner
    attr_reader :binary_path

    def initialize(binary_path)
      @binary_path = binary_path || "periphery"
    end

    def scan(options)
      stdout, stderr, status = Open3.capture3(*([binary_path, "scan"] + scan_arguments(options)))
      raise stderr unless status.success?
      stdout
    end

    def scan_arguments(options)
      options.
        reject { |_key, value| !value }.
        map { |key, value| value.is_a?(TrueClass) ? [key, nil] : [key, value] }.
        map { |key, value| ["--" + key.to_s.tr('_', '-'), value] }.
        flatten.
        compact
    end
  end
end
