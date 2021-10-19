module Periphery
  class ScanLogParser
    def parse(string)
      string.lines.map do |line|
        match = line.match(/^(?<path>.+):(?<line>\d+):(?<column>\d+): (?<message>.*)\n?$/)
        ScanLogEntry.new(*match.captures) if match
      end.compact
    end
  end

  ScanLogEntry = Struct.new(:path, :line, :column, :message) do
    def initialize(path, line, column, message)
      super(path, line.to_i, column.to_i, message)
    end
  end
end
