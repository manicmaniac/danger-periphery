# frozen_string_literal: true

require 'periphery'

module Danger
  # Analyze Swift files and detect unused codes in your project.
  # This is done using {https://github.com/peripheryapp/periphery Periphery}.
  #
  # @example Specifying options to Periphery.
  #
  #          periphery.scan(
  #            project: "Foo.xcodeproj"
  #            schemes: ["foo", "bar"],
  #            targets: "foo",
  #            clean_build: true
  #          )
  #
  # @see file:README.md
  # @tags swift
  class DangerPeriphery < Plugin
    # Path to Periphery executable.
    # By default the value is nil and the executable is searched from $PATH.
    # @return [String]
    attr_accessor :binary_path

    # A flag to force Periphery report problems about all files.
    # @return [Boolean] +true+ if it reports problems in all files.
    #                   Otherwise +false+, it reports about only changed files in this pull request.
    #                   By default +false+ is set.
    attr_accessor :scan_all_files

    # A flag to treat warnings as errors.
    # @return [Boolean] +true+ if this plugin reports all violations as errors.
    #                   Otherwise +false+, it reports violations as warnings.
    #                   By default +false+ is set.
    attr_accessor :warning_as_error

    # A flag to enable verbose output.
    # @return [Boolean] +true+ if this plugin prints all outputs from Periphery.
    #                   Otherwise returns +false+ and prints only errors.
    #                   Defaults to +false+.
    #                   Note that regardless of this value, this plugin always overrides certain options,
    #                   such as +--disable-update-check+, +--format+ and +--quiet+.
    # @see OPTION_OVERRIDES
    # @see format=
    attr_accessor :verbose

    # For internal use only.
    #
    # @return [Symbol]
    attr_writer :format

    OPTION_OVERRIDES = {
      disable_update_check: true,
      quiet: true
    }.freeze

    def initialize(dangerfile)
      super
      @format = :checkstyle
      @warning_as_error = false
    end

    # Scans Swift files.
    # Raises an error when Periphery executable is not found.
    #
    # @example Ignore all warnings from files matching regular expression
    #   periphery.scan do |violation|
    #     !violation.path.match(/.*\/generated\.swift/)
    #   end
    #
    # @param [Hash] options Options passed to Periphery with the following translation rules.
    #                       1. Replace all underscores with hyphens in each key.
    #                       2. Prepend double hyphens to each key.
    #                       3. If value is an array, transform it to comma-separated string.
    #                       4. If value is true, drop value and treat it as option without argument.
    #                       5. Override some options listed in {OPTION_OVERRIDES}.
    #                       Run +$ periphery help scan+ for available options.
    #
    # @yield [entry]        Block to process each warning just before showing it.
    # @yieldparam [Periphery::ScanResult] entry
    # @yieldreturn [Boolean, Periphery::ScanResult]
    #                       If the Proc returns falsy value, the warning corresponding to the given ScanResult will be
    #                       suppressed, otherwise not.
    #
    # @return [void]
    def scan(options = {})
      output = Periphery::Runner.new(binary_path).scan(options.merge(OPTION_OVERRIDES).merge(format: @format))
      files = files_in_diff unless @scan_all_files
      parser.parse(output).each do |entry|
        next unless @scan_all_files || files.include?(entry.path)

        next if block_given? && !yield(entry)

        report(entry.message, file: entry.path, line: entry.line)
      end
    end

    # The version of underlying Periphery executable.
    #
    # @return [string]
    def version
      Periphery::Runner.new(binary_path).version
    end

    # Download and install Periphery executable binary.
    #
    # @param [String, Symbol] version The version of Periphery you want to install.
    #                                 `:latest` is treated as special keyword that specifies the latest version.
    # @param [String] path            The path to install Periphery including the filename itself.
    # @param [Boolean] force          If `true`, an existing file will be overwritten. Otherwise an error occurs.
    # @return [void]
    def install(version: :latest, path: 'periphery', force: false)
      installer = Periphery::Installer.new(version)
      installer.install(path, force: force)
      self.binary_path = File.absolute_path(path)
    end

    private

    def report(*args, **kwargs)
      return self.fail(*args, **kwargs) if warning_as_error

      warn(*args, **kwargs)
    end

    def files_in_diff
      # Taken from https://github.com/ashfurrow/danger-ruby-swiftlint/blob/5184909aab00f12954088684bbf2ce5627e08ed6/lib/danger_plugin.rb#L214-L216
      renamed_files_hash = git.renamed_files.to_h { |rename| [rename[:before], rename[:after]] }
      post_rename_modified_files = git.modified_files.map do |modified_file|
        renamed_files_hash[modified_file] || modified_file
      end
      (post_rename_modified_files - git.deleted_files) + git.added_files
    end

    def parser
      case @format
      when :checkstyle
        Periphery::CheckstyleParser.new
      when :json
        Periphery::JsonParser.new
      else
        raise "#{@format} is unsupported"
      end
    end
  end
end
