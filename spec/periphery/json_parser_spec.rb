# frozen_string_literal: true

describe Periphery::JsonParser do
  subject(:parser) { described_class.new }

  describe '#parse' do
    subject(:parse) { parser.parse(string) }

    context 'with nil' do
      let(:string) { nil }

      it 'raises an error' do
        expect { parse }.to raise_error TypeError
      end
    end

    context 'with invalid string' do
      let(:string) { '' }

      it 'raises an error' do
        expect { parse }.to raise_error JSON::ParserError
      end
    end

    context 'with valid json' do
      let(:string) { File.read(fixture('scan.json')) }

      path = '/path/to/main.swift'
      expected = [
        Periphery::ScanResult.new(path, 1, 10,
                                  "Protocol 'RedundantProtocol' is redundant as it's never used as an existential type"),
        Periphery::ScanResult.new(path, 4, 25, "Protocol 'RedundantProtocol' conformance is redundant"),
        Periphery::ScanResult.new(path, 4, 14,
                                  "Class 'SomeClass' is declared public, but not used outside of the module"),
        Periphery::ScanResult.new(path, 7, 14, "Enum case 'unusedCase' is unused"),
        Periphery::ScanResult.new(path, 10, 9, "Property 'unusedProperty' is unused"),
        Periphery::ScanResult.new(path, 11, 17, "Property 'assignOnlyProperty' is assigned, but never used"),
        Periphery::ScanResult.new(path, 14, 17,
                                  "Function 'methodWithRedundantPublicAccessibility(_:)' is declared public, but not used outside of the module"),
        Periphery::ScanResult.new(path, 14, 58, "Parameter 'unusedParameter' is unused"),
        Periphery::ScanResult.new(path, 19, 10, "Function 'unusedMethod()' is unused")
      ]

      it 'returns correct ScanResults' do
        path = '/path/to/main.swift'

        # To use readable text diff, convert the result to flat text.
        expect(parse.flat_map(&:to_a).join("\n")).to eq expected.flat_map(&:to_a).join("\n")
      end
    end
  end

  describe '#parse_location' do
    subject(:parse_location) { parser.send(:parse_location, location) }

    context 'with valid location' do
      let(:location) { '/path/to/main.swift:1:42' }

      it 'returns path, line and column' do
        expect(parse_location).to eq ['/path/to/main.swift', 1, 42]
      end
    end

    context 'with invalid location' do
      let(:location) { '/' }

      it 'raises an error' do
        expect { parse_location }.to raise_error ArgumentError
      end
    end
  end

  describe '#compose_message' do
    subject(:message) { parser.send(:compose_message, name, kind, hints) }

    let(:name) { 'foo' }

    context 'with unused class' do
      let(:kind) { 'class' }
      let(:hints) { ['unused'] }

      it 'returns human-readable message' do
        expect(message).to eq "Class 'foo' is unused"
      end
    end

    context 'with unused parameter' do
      let(:kind) { 'var.parameter' }
      let(:hints) { ['unused'] }

      it 'returns human-readable message' do
        expect(message).to eq "Parameter 'foo' is unused"
      end
    end

    context 'with redundant protocol' do
      let(:kind) { 'protocol' }
      let(:hints) { ['redundantProtocol'] }

      it 'returns human-readable message' do
        expect(message).to eq "Protocol 'foo' is redundant as it's never used as an existential type"
      end
    end

    context 'with redundant protocol conformance' do
      let(:kind) { 'protocol' }
      let(:hints) { ['redundantConformance'] }

      it 'returns human-readable message' do
        expect(message).to eq "Protocol 'foo' conformance is redundant"
      end
    end

    context 'with redundant public accessibility' do
      let(:kind) { 'class' }
      let(:hints) { ['redundantPublicAccessibility'] }

      it 'returns human-readable message' do
        expect(message).to eq "Class 'foo' is declared public, but not used outside of the module"
      end
    end

    context 'with assign-only property' do
      let(:kind) { 'var.instance' }
      let(:hints) { ['assignOnlyProperty'] }

      it 'returns human-readable message' do
        expect(message).to eq "Property 'foo' is assigned, but never used"
      end
    end
  end

  describe '#display_name' do
    subject(:display_name) { parser.send(:display_name, kind) }

    context 'with valid kinds' do
      table = {
        'class' => 'class',
        'protocol' => 'protocol',
        'struct' => 'struct',
        'enum' => 'enum',
        'enumelement' => 'enum case',
        'typealias' => 'typealias',
        'associatedtype' => 'associatedtype',
        'function.constructor' => 'initializer',
        'extension' => 'extension',
        'extension.enum' => 'extension',
        'extension.class' => 'extension',
        'extension.struct' => 'extension',
        'extension.protocol' => 'extension',
        'function.method.class' => 'function',
        'function.method.static' => 'function',
        'function.method.instance' => 'function',
        'function.free' => 'function',
        'function.operator' => 'function',
        'function.subscript' => 'function',
        'var.static' => 'property',
        'var.instance' => 'property',
        'var.class' => 'property',
        'var.global' => 'property',
        'var.local' => 'property',
        'var.parameter' => 'parameter',
        'generic_type_param' => 'generic type parameter'
      }

      it 'returns human-readable name' do
        expect(table.keys.map { |kind| parser.send(:display_name, kind) }).to eq table.values
      end
    end

    context 'with nil' do
      let(:kind) { nil }

      it { is_expected.to be_nil }
    end
  end
end
