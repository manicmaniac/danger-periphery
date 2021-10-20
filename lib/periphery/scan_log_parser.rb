module Periphery
  class ScanLogParser
    def parse(string)
      string.lines.map do |line|
        match = line.match(/^(?<path>.+):(?<line>\d+):(?<column>\d+): (?<message>.*)\n?$/)
        ScanLogEntry.new(relative_path(match[:path]), match[:line].to_i, match[:column].to_i, match[:message]) if match
      end.compact
    end

    private

    def relative_path(path, base = Dir.pwd)
      Pathname.new(path).relative_path_from(base).to_s
    end
  end

  ScanLogEntry = Struct.new(:path, :line, :column, :message)
end
