# frozen_string_literal: true

module Periphery
  ScanResult = Struct.new(:path, :line, :column, :message)
end
