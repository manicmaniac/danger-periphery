require "periphery/runner"
require "periphery/scan_log_parser"

module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  Ryosuke Ito/danger-periphery
  # @tags monday, weekends, time, rattata
  #
  class DangerPeriphery < Plugin
    # An attribute that you can read/write from your Dangerfile
    #
    # @return   String
    attr_accessor :binary_path

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #
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
