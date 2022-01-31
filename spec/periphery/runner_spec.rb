# frozen_string_literal: true

describe Periphery::Runner do
  subject(:runner) { described_class.new(binary_path) }

  let(:binary_path) { binary("periphery") }

  describe "#scan" do
    subject { runner.scan(options) }

    context "with valid args" do
      let(:options) do
        {
          project: fixture("test.xcodeproj"),
          targets: "test",
          "schemes" => "test"
        }
      end

      let(:command) do
        [
          binary_path,
          "scan",
          "--project",
          fixture("test.xcodeproj"),
          "--targets",
          "test",
          "--schemes",
          "test"
        ]
      end

      it "runs scan without args" do
        status = double(Process::Status, success?: true)
        expect(Open3).to receive(:capture3).once.with(*command).and_return ["warning:", "", status]
        expect(subject).to include "warning:"
      end
    end
  end

  describe "#scan_arguments" do
    subject { runner.scan_arguments(options) }

    context "with empty options" do
      let(:options) { {} }

      it { is_expected.to be_empty }
    end

    context "with options that takes no argument" do
      let(:options) do
        {
          clean_build: true,
          skip_build: true
        }
      end

      it "returns correct arguments" do
        expect(subject).to eq %w(--clean-build --skip-build)
      end
    end

    context "with options that takes an argument" do
      let(:options) do
        {
          project: "test.xcodeproj",
          targets: "test1,test2"
        }
      end

      it "returns correct arguments" do
        expect(subject).to eq %w(--project test.xcodeproj --targets test1,test2)
      end
    end

    context "with options that takes an array as argument" do
      let(:options) do
        {
          project: "test.xcodeproj",
          targets: %w(test1 test2)
        }
      end

      it "returns correct arguments" do
        expect(subject).to eq %w(--project test.xcodeproj --targets test1,test2)
      end
    end
  end
end
