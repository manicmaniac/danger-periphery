# frozen_string_literal: true

describe Danger::DangerPeriphery do
  include DangerPluginHelper

  subject(:warnings) { dangerfile.status_report[:warnings] }

  let(:dangerfile) { testing_dangerfile }
  let(:periphery) { dangerfile.periphery }
  let(:periphery_options) do
    {
      project: fixture('test.xcodeproj'),
      targets: 'test',
      schemes: 'test'
    }
  end
  let(:periphery_executable) { fixture('mock-periphery') }

  before do
    periphery.binary_path = periphery_executable
    allow(Pathname).to receive(:getwd).and_return fixtures_path
    allow(periphery.git).to receive_messages(
      renamed_files: [],
      modified_files: ['test/main.swift'],
      deleted_files: [],
      added_files: []
    )
  end

  it 'is a plugin' do
    expect(described_class.new(nil)).to be_a Danger::Plugin
  end

  context 'when periphery is not installed' do
    let(:periphery_executable) { 'not_installed' }

    it 'fails with error' do
      expect { periphery.scan }.to raise_error Errno::ENOENT
    end
  end

  context 'with block' do
    before { periphery.scan(periphery_options, &block) }

    context 'when the block returns nil' do
      let(:block) { ->(violation) {} }

      it 'filters out all warnings' do
        expect(warnings).to be_empty
      end
    end

    context 'when the block returns false' do
      let(:block) { ->(_violation) { false } }

      it 'filters out all warnings' do
        expect(warnings).to be_empty
      end
    end

    context 'when the block returns true' do
      let(:block) { ->(_violation) { true } }

      it 'reports warnings without filtering anything' do
        expect(warnings).to include "Function 'unusedMethod()' is unused"
      end
    end

    context 'when the block returns truthy value' do
      let(:block) { ->(_violation) { 0 } }

      it 'reports warnings without filtering anything' do
        expect(warnings).to include "Function 'unusedMethod()' is unused"
      end
    end

    context 'when the block modifies the given violation' do
      let(:block) { ->(violation) { violation.message.gsub!(/Function/, 'Foobar') } }

      it 'reports modified warnings' do
        expect(warnings).to include "Foobar 'unusedMethod()' is unused"
      end
    end
  end

  describe '#postprocessor' do
    before do
      periphery.postprocessor = postprocessor
      periphery.scan(periphery_options)
    end

    context 'when returns nil' do
      let(:postprocessor) { ->(path, line, column, message) {} }

      it 'does not report warnings' do
        expect(warnings).to be_empty
      end
    end

    context 'when returns false' do
      let(:postprocessor) { ->(_path, _line, _column, _message) { false } }

      it 'does not report warnings' do
        expect(warnings).to be_empty
      end
    end

    context 'when returns true' do
      let(:postprocessor) { ->(_path, _line, _column, _message) { true } }

      it 'reports warnings' do
        expect(warnings).to include "Function 'unusedMethod()' is unused"
      end
    end

    context 'when returns a modified array' do
      let(:postprocessor) do
        ->(path, line, column, message) { [path, line, column, message.gsub(/Function/, 'Foobar')] }
      end

      it 'reports modified warnings' do
        expect(warnings).to include "Foobar 'unusedMethod()' is unused"
      end
    end
  end

  describe '#process_warnings' do
    it 'sets postprocessor' do
      periphery.process_warnings do |_path, _line, _column, _message|
        nil
      end
      expect { periphery.process_warnings { |*_args| nil } }.to change(periphery, :postprocessor)
    end
  end
end