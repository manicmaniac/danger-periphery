# frozen_string_literal: true

describe Danger::DangerPeriphery, :slow do
  include DangerPluginHelper

  subject(:warnings) { dangerfile.status_report[:warnings] }

  include_context 'when test.xcodeproj is indexed'

  let(:dangerfile) { testing_dangerfile }
  let(:periphery) { dangerfile.periphery }
  let(:added_files) { [] }
  let(:modified_files) { [] }
  let(:periphery_options) do
    {
      project: fixture('test.xcodeproj'),
      targets: 'test',
      schemes: 'test',
      skip_build: true,
      index_store_path: index_store_path
    }
  end

  before do
    periphery.binary_path = binary('periphery')
    json = File.read(fixture('github_pr.json'))
    allow(periphery.github).to receive(:pr_json).and_return json
    allow(Pathname).to receive(:getwd).and_return fixtures_path
    allow(periphery.git).to receive_messages(
      renamed_files: [],
      modified_files: modified_files,
      deleted_files: [],
      added_files: added_files
    )
    periphery.scan(periphery_options)
  end

  context 'when .swift files are not in diff' do
    it 'reports nothing' do
      expect(warnings).to be_empty
    end
  end

  context 'when .swift files are added' do
    let(:added_files) { ['test/main.swift'] }

    it 'reports unused code' do
      expect(warnings).to include "Function 'unusedMethod()' is unused"
    end
  end

  context 'when .swift files are modified' do
    let(:modified_files) { ['test/main.swift'] }

    it 'reports unused code' do
      expect(warnings).to include "Function 'unusedMethod()' is unused"
    end
  end
end
