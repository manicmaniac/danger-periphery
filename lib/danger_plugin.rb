# frozen_string_literal: true

require "periphery"

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

    # Proc object to process each warnings just before showing them.
    # The Proc must receive 4 arguments: path, line, column, message
    # and return one of:
    #   - an array that contains 4 elements [path, line, column, message]
    #   - true
    #   - false
    #   - nil
    # If Proc returns an array, the warning will be raised based on returned elements.
    # If Proc returns true, the warning will not be modified.
    # If Proc returns false or nil, the warning will be ignored.
    #
    # By default the Proc returns true.
    # @return [Proc]
    attr_accessor :postprocessor

    OPTION_OVERRIDES = {
      disable_update_check: true,
      format: "checkstyle",
      quiet: true
    }.freeze

    def initialize(dangerfile)
      super(dangerfile)
      @postprocessor = ->(path, line, column, message) { true }
    end

    # Scans Swift files.
    # Raises an error when Periphery executable is not found.
    #
    # @param [Hash] options Options passed to Periphery with the following translation rules.
    #                       1. Replace all underscores with hyphens in each key.
    #                       2. Prepend double hyphens to each key.
    #                       3. If value is an array, transform it to comma-separated string.
    #                       4. If value is true, drop value and treat it as option without argument.
    #                       5. Override some options listed in {OPTION_OVERRIDES}.
    # @return [void]
    def scan(**options, &block)
      output = Periphery::Runner.new(binary_path).scan(options.merge(OPTION_OVERRIDES))
      files = files_in_diff
      Periphery::CheckstyleParser.new.parse(output).
        lazy.
        select { |entry| files.include?(entry.path) }.
        map { |entry| postprocess(entry, &block) }.
        force.
        compact.
        each { |path, line, column, message| warn(message, file: path, line: line) }
    end

    # Convenience method to set {#postprocessor} with block.
    #
    # @return [Proc]
    #
    # @example Ignore all warnings from files matching regular expression
    #   periphery.process_warnings do |path, line, column, message|
    #     ! path.match(/.*\/generated\.swift/)
    #   end
    def process_warnings(&block)
      @postprocessor = block
    end

    private

    def files_in_diff
      # Taken from https://github.com/ashfurrow/danger-ruby-swiftlint/blob/5184909aab00f12954088684bbf2ce5627e08ed6/lib/danger_plugin.rb#L214-L216
      renamed_files_hash = git.renamed_files.to_h { |rename| [rename[:before], rename[:after]] }
      post_rename_modified_files = git.modified_files.map { |modified_file| renamed_files_hash[modified_file] || modified_file }
      (post_rename_modified_files - git.deleted_files) + git.added_files
    end

    def postprocess(entry, &block)
      if block
        if block.call(entry)
          [entry.path, entry.line, entry.column, entry.message]
        end
      else
        result = @postprocessor.call(entry.path, entry.line, entry.column, entry.message)
        if !result
          nil
        elsif result.kind_of?(TrueClass)
          [entry.path, entry.line, entry.column, entry.message]
        elsif result.kind_of?(Array) && result.size == 4
          result
        else
          raise "Proc passed to postprocessor must return one of nil, true, false and Array that includes 4 elements."
        end
      end
    end
  end
end
