# frozen_string_literal: true

describe Periphery::CheckstyleParser do
  subject(:parser) { described_class.new }

  describe '#parse' do
    subject(:parse) { parser.parse(string) }

    context 'with vaild checkstyle xml' do
      let(:string) do
        <<~LOG
          <?xml version="1.0" encoding="utf-8"?>
          <checkstyle version="4.3">
            <file name="/Users/manicmaniac/danger-periphery/main.swift">
                <error line="1" column="1" severity="warning" message="Typealias &apos;UnusedTypeAlias&apos; is unused"/>
                <error line="2" column="1" severity="warning" message="Class &apos;UnusedClass&apos; is unused"/>
                <error line="3" column="1" severity="warning" message="Protocol &apos;UnusedProtocol&apos; is unused"/>
            </file>
          </checkstyle>
        LOG
      end

      before { allow(Pathname).to receive(:getwd).and_return Pathname.new('/Users/manicmaniac/danger-periphery') }

      it 'parses all warnings' do
        expect(parse).to eq [
          Periphery::ScanResult.new('main.swift', 1, 1, "Typealias 'UnusedTypeAlias' is unused"),
          Periphery::ScanResult.new('main.swift', 2, 1, "Class 'UnusedClass' is unused"),
          Periphery::ScanResult.new('main.swift', 3, 1, "Protocol 'UnusedProtocol' is unused")
        ]
      end
    end
  end
end
