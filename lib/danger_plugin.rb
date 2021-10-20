# frozen_string_literal: true

require "periphery/runner"
require "periphery/scan_log_parser"

module Danger
  # Analyze Swift files and detect unused codes in your project.
  # This is done using [Periphery](https://github.com/peripheryapp/periphery).
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
  # @see manicmaniac/danger-periphery
  # @tags swift
  class DangerPeriphery < Plugin
    # Path to Periphery executable.
    # By default the value is nil and the executable is searched from $PATH.
    # @return [String]
    attr_accessor :binary_path

    # Scans Swift files.
    # Raises an error when Periphery executable is not found.
    #
    # @param [Hash] options Options passed to Periphery with the following translation rules.
    #                       1. Replace all underscores with hyphens in each key.
    #                       2. Prepend double hyphens to each key.
    #                       3. If value is an array, transform it to comma-separated string.
    #                       4. If value is true, drop value and treat it as option without argument.
    #                       5. Override some options like --disable-update-check, --format, --quiet and so.
    # @return [void]
    def scan(**options)
      output = Periphery::Runner.new(binary_path).scan(options.merge(disable_update_check: true, format: "xcode", quiet: true))
      entries = Periphery::ScanLogParser.new.parse(output)
      files = files_in_diff
      entries.
        select { |entry| files.include?(entry.path) }.
        each { |entry| warn(entry.message, file: entry.path, line: entry.line) }
    end

    private

    def files_in_diff
      # Taken from https://github.com/ashfurrow/danger-ruby-swiftlint/blob/5184909aab00f12954088684bbf2ce5627e08ed6/lib/danger_plugin.rb#L214-L216
      renamed_files_hash = git.renamed_files.map { |rename| [rename[:before], rename[:after]] }.to_h
      post_rename_modified_files = git.modified_files.map { |modified_file| renamed_files_hash[modified_file] || modified_file }
      (post_rename_modified_files - git.deleted_files) + git.added_files
    end
  end
end
