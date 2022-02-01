# frozen_string_literal: true

describe Danger::DangerPeriphery do
  include DangerPluginHelper

  it "should be a plugin" do
    expect(Danger::DangerPeriphery.new(nil)).to be_a Danger::Plugin
  end

  context "with Dangerfile" do
    let(:dangerfile) { testing_dangerfile }
    let(:periphery) { dangerfile.periphery }

    before do
      periphery.binary_path = binary("periphery")
      json = File.read("#{File.dirname(__FILE__)}/support/fixtures/github_pr.json") # example json: `curl https://api.github.com/repos/danger/danger-plugin-template/pulls/18 > github_pr.json`
      allow(periphery.github).to receive(:pr_json).and_return(json)
      allow(Pathname).to receive(:getwd).and_return fixtures_path
    end

    context "when periphery is not installed" do
      before { periphery.binary_path = "not_installed" }

      it "fails with error" do
        expect { periphery.scan }.to raise_error Errno::ENOENT
      end
    end

    context "when .swift files not in diff" do
      before do
        allow(periphery.git).to receive(:renamed_files).and_return []
        allow(periphery.git).to receive(:modified_files).and_return []
        allow(periphery.git).to receive(:deleted_files).and_return []
        allow(periphery.git).to receive(:added_files).and_return []
      end

      it "reports nothing" do
        periphery.scan(
          project: fixture("test.xcodeproj"),
          targets: "test",
          schemes: "test"
        )

        expect(dangerfile.status_report[:warnings]).to be_empty
      end
    end

    context "when .swift files were added" do
      before do
        allow(periphery.git).to receive(:renamed_files).and_return []
        allow(periphery.git).to receive(:modified_files).and_return []
        allow(periphery.git).to receive(:deleted_files).and_return []
        allow(periphery.git).to receive(:added_files).and_return ["test/main.swift"]
      end

      it "reports unused code" do
        periphery.scan(
          project: fixture("test.xcodeproj"),
          targets: "test",
          schemes: "test"
        )

        expect(dangerfile.status_report[:warnings]).to include "Function 'unusedMethod()' is unused"
      end
    end

    context "when .swift files were modified" do
      before do
        allow(periphery.git).to receive(:renamed_files).and_return []
        allow(periphery.git).to receive(:modified_files).and_return ["test/main.swift"]
        allow(periphery.git).to receive(:deleted_files).and_return []
        allow(periphery.git).to receive(:added_files).and_return []
      end

      it "reports unused code" do
        periphery.scan(
          project: fixture("test.xcodeproj"),
          targets: "test",
          schemes: "test"
        )

        expect(dangerfile.status_report[:warnings]).to include "Function 'unusedMethod()' is unused"
      end
    end
  end
end
