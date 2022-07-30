# frozen_string_literal: true

require 'json'
require 'periphery/scan_result'

module Periphery
  # Parses JSON formatted output produced by Periphery with +--format=json+ option.
  class JsonParser
    def parse(string)
      JSON.parse(string).map do |entry|
        path, line, column = parse_location(entry['location'])
        message = compose_message(*entry.slice('name', 'kind', 'hints').values)
        ScanResult.new(path, line, column, message)
      end
    end

    private

    # Parses a string like '/path/to/file.swift:19:10'
    def parse_location(location)
      location.scan(/^(.+):(\d+):(\d+)$/) do |path, line, column|
        return [path, line.to_i, column.to_i]
      end
      raise ArgumentError, "#{location} is not in a valid format"
    end

    def compose_message(name, kind, hints)
      return 'unused' unless name

      message = ''.dup
      message += display_name(kind).capitalize if kind
      message += ' '
      message += "'#{name}'"
      message += ' '

      # Assumes hints contains only one item.
      # https://github.com/peripheryapp/periphery/blob/2.9.0/Sources/Frontend/Formatters/JsonFormatter.swift#L27
      # https://github.com/peripheryapp/periphery/blob/2.9.0/Sources/Frontend/Formatters/JsonFormatter.swift#L42
      case hints[0]
      when 'unused'
        message += 'is unused'
      when 'assignOnlyProperty'
        message += 'is assigned, but never used'
      when 'redundantProtocol'
        message += "is redundant as it's never used as an existential type"
      when 'redundantConformance'
        message += 'conformance is redundant'
      when 'redundantPublicAccessibility'
        # FIXME: There's no information about the name of module in JSON output,
        #        unlike other formatters can output `outside of FooModule`.
        #        This is known problem and may be fixed in future Periphery's release.
        #        See the status of https://github.com/peripheryapp/periphery/pull/519
        message += 'is declared public, but not used outside of the module'
      end
      message
    end

    def display_name(kind)
      case kind
      when 'enumelement'
        'enum case'
      when 'function.constructor'
        'initializer'
      when 'var.parameter'
        'parameter'
      when 'generic_type_param'
        'generic type parameter'
      when nil
        nil
      else
        return 'property' if kind.start_with?('var')

        kind.split('.', 2).first
      end
    end
  end
end
