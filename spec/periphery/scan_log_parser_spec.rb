# frozen_string_literal: true

require "periphery/scan_log_parser"

module Periphery
  describe ScanLogParser do
    describe "#parse" do
      subject { described_class.new.parse(string) }

      context "with empty string" do
        let(:string) { "" }

        it { is_expected.to be_empty }
      end

      context "with a valid string" do
        let(:string) do
          <<~EOS
          * Inspecting project...
          * Building danger-periphery...
          * Indexing...
          * Analyzing...

          /Users/manicmaniac/danger-periphery/main.swift:1:1: warning: Typealias 'UnusedTypeAlias' is unused
          /Users/manicmaniac/danger-periphery/main.swift:2:1: warning: Class 'UnusedClass' is unused
          /Users/manicmaniac/danger-periphery/main.swift:3:1: warning: Protocol 'UnusedProtocol' is unused

          * Seeing false positives?
          - Periphery only analyzes files that are members of the targets you specify.
            References to declarations identified as unused may reside in files that are members of other targets, e.g test targets.
          - By default, Periphery does not assume that all public declarations are in use.
            You can instruct it to do so with the --retain-public option.
          - Periphery is a very precise tool, false positives often turn out to be correct after further investigation.
          - If it really is a false positive, please report it - https://github.com/peripheryapp/periphery/issues.
          EOS
        end

        before { allow(Pathname).to receive(:getwd).and_return Pathname.new("/Users/manicmaniac/danger-periphery") }

        it "parses all warnings without garbages" do
          expect(subject).to eq [
            ScanLogEntry.new("main.swift", 1, 1, "warning: Typealias 'UnusedTypeAlias' is unused"),
            ScanLogEntry.new("main.swift", 2, 1, "warning: Class 'UnusedClass' is unused"),
            ScanLogEntry.new("main.swift", 3, 1, "warning: Protocol 'UnusedProtocol' is unused")
          ]
        end
      end
    end
  end
end
