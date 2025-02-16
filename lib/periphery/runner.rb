# frozen_string_literal: true

require 'open3'
require 'rubygems/version'

module Periphery
  class Runner # :nodoc:
    attr_reader :binary_path, :verbose

    def initialize(binary_path, on_spawn: nil, verbose: false)
      @binary_path = binary_path || 'periphery'
      @on_spawn = on_spawn
      @verbose = verbose
    end

    def scan(options)
      arguments = [binary_path, 'scan'] + scan_arguments(options)
      stdout, stderr, status = capture_output(arguments)
      validate_subprocess_status!(arguments, status, stderr)

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
      validate_subprocess_status!(arguments, status, stderr)

      stdout.string.strip
    end

    private

    def capture_output(arguments)
      out = StringIO.new
      err = StringIO.new
      status = Open3.popen3(*arguments, in: :close) do |_, stdout, stderr, wait_thread|
        @on_spawn&.call(wait_thread.pid)
        threads = []
        begin
          threads << tee(stdout, verbose ? [out, $stdout] : [out])
          threads << tee(stderr, verbose ? [err, $stderr] : [err])
          status = wait_thread.value
          threads.each(&:join)
          status
        ensure
          threads.each(&:kill)
        end
      end
      [out, err, status]
    end

    def validate_subprocess_status!(arguments, status, stderr)
      case status.success?
      when false
        raise "error: #{arguments} exited with status code #{status.exitstatus}. #{stderr.string}"
      when nil
        raise "error: #{arguments} was terminated by SIG#{Signal.signame(status.termsig)}"
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
