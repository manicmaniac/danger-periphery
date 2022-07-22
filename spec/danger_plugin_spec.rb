# frozen_string_literal: true

describe Danger::DangerPeriphery do
  include DangerPluginHelper

  let(:periphery_options) do
    {
      project: fixture('test.xcodeproj'),
      targets: 'test',
      schemes: 'test'
    }
  end

  it 'is a plugin' do
    expect(Danger::DangerPeriphery.new(nil)).to be_a Danger::Plugin
  end

  context 'with Dangerfile' do
    let(:dangerfile) { testing_dangerfile }
    let(:periphery) { dangerfile.periphery }

    before do
      periphery.binary_path = fixture('mock-periphery')
      # example json: `curl -o github_pr.json https://api.github.com/repos/danger/danger-plugin-template/pulls/18
      json = File.read(fixture('github_pr.json'))
      allow(periphery.github).to receive(:pr_json).and_return json
      allow(Pathname).to receive(:getwd).and_return fixtures_path
    end

    context 'when periphery is not installed' do
      before { periphery.binary_path = 'not_installed' }

      it 'fails with error' do
        expect { periphery.scan }.to raise_error Errno::ENOENT
      end
    end

    context 'with a real periphery executable', :slow do
      before { periphery.binary_path = binary('periphery') }

      context 'when .swift files not in diff' do
        before do
          allow(periphery.git).to receive(:renamed_files).and_return []
          allow(periphery.git).to receive(:modified_files).and_return []
          allow(periphery.git).to receive(:deleted_files).and_return []
          allow(periphery.git).to receive(:added_files).and_return []
        end

        it 'reports nothing' do
          periphery.scan(periphery_options)

          expect(dangerfile.status_report[:warnings]).to be_empty
        end
      end

      context 'when .swift files were added' do
        before do
          allow(periphery.git).to receive(:renamed_files).and_return []
          allow(periphery.git).to receive(:modified_files).and_return []
          allow(periphery.git).to receive(:deleted_files).and_return []
          allow(periphery.git).to receive(:added_files).and_return ['test/main.swift']
        end

        it 'reports unused code' do
          periphery.scan(periphery_options)

          expect(dangerfile.status_report[:warnings]).to include "Function 'unusedMethod()' is unused"
        end
      end

      context 'when .swift files were modified' do
        before do
          allow(periphery.git).to receive(:renamed_files).and_return []
          allow(periphery.git).to receive(:modified_files).and_return ['test/main.swift']
          allow(periphery.git).to receive(:deleted_files).and_return []
          allow(periphery.git).to receive(:added_files).and_return []
        end

        it 'reports unused code' do
          periphery.scan(periphery_options)

          expect(dangerfile.status_report[:warnings]).to include "Function 'unusedMethod()' is unused"
        end
      end
    end

    context 'with block' do
      subject { dangerfile.status_report[:warnings] }

      before do
        allow(periphery.git).to receive(:renamed_files).and_return []
        allow(periphery.git).to receive(:modified_files).and_return ['test/main.swift']
        allow(periphery.git).to receive(:deleted_files).and_return []
        allow(periphery.git).to receive(:added_files).and_return []
        periphery.scan(periphery_options, &block)
      end

      context 'that returns nil' do
        let(:block) { ->(violation) {} }

        it 'filters out all warnings' do
          expect(subject).to be_empty
        end
      end

      context 'that returns false' do
        let(:block) { ->(_violation) { false } }

        it 'filters out all warnings' do
          expect(subject).to be_empty
        end
      end

      context 'that returns true' do
        let(:block) { ->(_violation) { true } }

        it 'reports warnings without filtering anything' do
          expect(subject).to include "Function 'unusedMethod()' is unused"
        end
      end

      context 'that returns truthy value' do
        let(:block) { ->(_violation) { 0 } }

        it 'reports warnings without filtering anything' do
          expect(subject).to include "Function 'unusedMethod()' is unused"
        end
      end

      context 'that modifies the given violation' do
        let(:block) { ->(violation) { violation.message.gsub!(/Function/, 'Foobar') } }

        it 'reports modified warnings' do
          expect(subject).to include "Foobar 'unusedMethod()' is unused"
        end
      end
    end

    describe '#postprocessor' do
      subject { dangerfile.status_report[:warnings] }

      before do
        allow(periphery.git).to receive(:renamed_files).and_return []
        allow(periphery.git).to receive(:modified_files).and_return ['test/main.swift']
        allow(periphery.git).to receive(:deleted_files).and_return []
        allow(periphery.git).to receive(:added_files).and_return []
        periphery.postprocessor = postprocessor
        periphery.scan(periphery_options)
      end

      context 'when returns nil' do
        let(:postprocessor) { ->(path, line, column, message) {} }

        it 'does not report warnings' do
          expect(subject).to be_empty
        end
      end

      context 'when returns false' do
        let(:postprocessor) { ->(_path, _line, _column, _message) { false } }

        it 'does not report warnings' do
          expect(subject).to be_empty
        end
      end

      context 'when returns true' do
        let(:postprocessor) { ->(_path, _line, _column, _message) { true } }

        it 'reports warnings' do
          expect(subject).to include "Function 'unusedMethod()' is unused"
        end
      end

      context 'when returns a modified array' do
        let(:postprocessor) do
          ->(path, line, column, message) { [path, line, column, message.gsub(/Function/, 'Foobar')] }
        end

        it 'reports modified warnings' do
          expect(subject).to include "Foobar 'unusedMethod()' is unused"
        end
      end
    end

    describe '#process_warnings' do
      it 'sets postprocessor' do
        periphery.process_warnings do |_path, _line, _column, _message|
          nil
        end
        expect { periphery.process_warnings { |*_args| nil } }.to(change { periphery.postprocessor })
      end
    end
  end
end
