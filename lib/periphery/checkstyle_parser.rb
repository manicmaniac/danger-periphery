# frozen_string_literal: true

require 'pathname'
require 'periphery/scan_result'
require 'rexml/parsers/streamparser'
require 'rexml/streamlistener'

module Periphery
  class CheckstyleParser
    class Listener
      include REXML::StreamListener

      attr_reader :results

      def initialize
        @current_file = nil
        @results = []
      end

      def tag_start(name, attrs)
        case name
        when 'file'
          @current_file = relative_path(attrs['name'])
        when 'error'
          if @current_file
            @results << ScanResult.new(
              @current_file,
              attrs['line'].to_i,
              attrs['column'].to_i,
              attrs['message']
            )
          end
        end
      end

      def tag_end(name)
        @current_file = nil if name == 'file'
      end

      private

      def relative_path(path, base = Pathname.getwd)
        Pathname.new(path).relative_path_from(base).to_s
      end
    end

    def parse(string)
      listener = Listener.new
      REXML::Parsers::StreamParser.new(string, listener).parse
      listener.results
    end
  end
end
