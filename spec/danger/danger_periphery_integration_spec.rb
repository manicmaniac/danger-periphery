# frozen_string_literal: true

describe Danger::DangerPeriphery, :slow do
  include DangerPluginHelper

  subject(:warnings) { dangerfile.status_report[:warnings] }

  include_context 'when test.xcodeproj is indexed'

  let(:dangerfile) { testing_dangerfile }
  let(:periphery) { dangerfile.periphery.tap { |p| p.binary_path = binary('periphery') } }
  let(:added_files) { [] }
  let(:modified_files) { [] }
  let(:periphery_options) do
    options = {
      project: fixture('test.xcodeproj'),
      schemes: 'test',
      skip_build: true,
      index_store_path: index_store_path
    }
    # `--targets` option has disappeared since Periphery >= 3.0.0.
    options[:targets] = targets if Gem::Version.new(periphery.version) < Gem::Version.new('3.0.0')
    options
  end
  let(:targets) { 'test' }

  before do
    next skip 'periphery is not installed' unless File.exist?(periphery.binary_path)

    json = File.read(fixture('github_pr.json'))
    allow(periphery.github).to receive(:pr_json).and_return json
    allow(Pathname).to receive(:getwd).and_return fixtures_path
    allow(periphery.git).to receive_messages(
      renamed_files: [],
      modified_files: modified_files,
      deleted_files: [],
      added_files: added_files
    )
  end

  context 'when .swift files are not in diff' do
    it 'reports nothing' do
      periphery.scan(periphery_options)
      expect(warnings).to be_empty
    end
  end

  context 'when .swift files are added' do
    let(:added_files) { ['test/main.swift'] }

    it 'reports unused code' do
      periphery.scan(periphery_options)
      expect(warnings).to include "Function 'unusedMethod()' is unused"
    end
  end

  context 'when .swift files are modified' do
    let(:modified_files) { ['test/main.swift'] }

    it 'reports unused code' do
      periphery.scan(periphery_options)
      expect(warnings).to include "Function 'unusedMethod()' is unused"
    end
  end

  context 'when multiple targets are analyzed' do
    let(:targets) { %w[test unit-test] }

    it 'does not raise any error' do
      expect { periphery.scan(periphery_options) }.not_to raise_error
    end
  end
end
