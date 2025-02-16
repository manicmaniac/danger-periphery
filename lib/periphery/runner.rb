# frozen_string_literal: true

require 'rubygems/version'

module Periphery
  class Runner # :nodoc:
    attr_reader :binary_path, :verbose

    def initialize(binary_path)
      @binary_path = binary_path || 'periphery'
      @verbose = false
    end

    def scan(options)
      arguments = [binary_path, 'scan'] + scan_arguments(options)
      stdout, stderr, status = capture_output(arguments)
      raise "error: #{arguments} exited with status code #{status.exitstatus}. #{stderr.string}" unless status.success?

      stdout.string
    end

    def scan_arguments(options)
      args = []
      options.each do |key, value|
        next unless value

        next if key == :build_args

        value = nil if value.is_a?(TrueClass)
        args << "--#{key.to_s.tr('_', '-')}"
        if value.is_a?(Array)
          if Gem::Version.new(version) >= Gem::Version.new('2.18.0')
            args.push(*value.map(&:to_s))
          else
            args << value.join(',')
          end
        elsif value
          args << value&.to_s
        end
      end
      args += ['--', options[:build_args]] if options[:build_args]
      args
    end

    def version
      arguments = [binary_path, 'version']
      stdout, stderr, status = capture_output(arguments)
      raise "error: #{arguments} existed with status code #{status.exitstatus}. #{stderr.string}" unless status.success?

      stdout.string.strip
    end

    private

    def capture_output(arguments)
      IO.pipe do |out_r, out_w|
        IO.pipe do |err_r, err_w|
          stdout = StringIO.new
          stderr = StringIO.new
          pid = spawn(*arguments, in: :close, out: out_w, err: err_w)
          out_w.close
          err_w.close
          threads = [
            tee(out_r, verbose ? [stdout, $stdout] : [stdout]),
            tee(err_r, verbose ? [stderr, $stderr] : [stderr])
          ]
          _, status = Process.wait2(pid)
          threads.each(&:join)
          [stdout, stderr, status]
        end
      end
    end

    def tee(in_io, out_ios)
      Thread.new do
        until in_io.eof?
          data = in_io.readpartial(1024)
          out_ios.each { |io| io.write(data) }
        end
      end
    end
  end
end
