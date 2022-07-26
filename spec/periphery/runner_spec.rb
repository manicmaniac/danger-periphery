# frozen_string_literal: true

describe Periphery::Runner do
  subject(:runner) { described_class.new(binary_path) }

  let(:binary_path) { binary('periphery') }

  describe '#scan' do
    subject(:scan) { runner.scan(options) }

    let(:options) do
      {
        project: fixture('test.xcodeproj'),
        targets: 'test',
        'schemes' => 'test'
      }
    end

    let(:command) do
      [
        binary_path,
        'scan',
        '--project',
        fixture('test.xcodeproj'),
        '--targets',
        'test',
        '--schemes',
        'test'
      ]
    end

    context 'when periphery succeeds' do
      it 'returns scan result' do
        status = instance_double(Process::Status, success?: true)
        allow(Open3).to receive(:capture3).once.with(*command).and_return ['warning:', '', status]
        expect(scan).to include 'warning:'
      end
    end

    context 'when periphery fails' do
      it 'raises an error' do
        status = instance_double(Process::Status, success?: false, exitstatus: 42)
        allow(Open3).to receive(:capture3).once.with(*command).and_return ['', 'foo', status]
        expect { scan }.to raise_error(RuntimeError, /42.*foo/)
      end
    end

    context 'when periphery executable is missing' do
      it 'raises an error' do
        allow(Open3).to receive(:capture3).once.with(*command).and_raise(Errno::ENOENT, '/path/to/periphery')
        expect { scan }.to raise_error(Errno::ENOENT, %r{/path/to/periphery})
      end
    end
  end

  describe '#scan_arguments' do
    subject(:scan_arguments) { runner.scan_arguments(options) }

    context 'with empty options' do
      let(:options) { {} }

      it { is_expected.to be_empty }
    end

    context 'with options that takes no argument' do
      let(:options) do
        {
          clean_build: true,
          skip_build: true
        }
      end

      it 'returns correct arguments' do
        expect(scan_arguments).to eq %w[--clean-build --skip-build]
      end
    end

    context 'with options that takes an argument' do
      let(:options) do
        {
          project: 'test.xcodeproj',
          targets: 'test1,test2'
        }
      end

      it 'returns correct arguments' do
        expect(scan_arguments).to eq %w[--project test.xcodeproj --targets test1,test2]
      end
    end

    context 'with options that takes an array as argument' do
      let(:options) do
        {
          project: 'test.xcodeproj',
          targets: %w[test1 test2]
        }
      end

      it 'returns correct arguments' do
        expect(scan_arguments).to eq %w[--project test.xcodeproj --targets test1,test2]
      end
    end

    context 'with options passed as symbol' do
      let(:options) do
        {
          project: 'test.xcodeproj',
          targets: :test
        }
      end

      it 'returns correct arguments' do
        expect(scan_arguments).to eq %w[--project test.xcodeproj --targets test]
      end
    end

    context 'with options passed as boolean' do
      let(:options) do
        {
          project: 'test.xcodeproj',
          targets: 'test',
          clean_build: true
        }
      end

      it 'returns correct arguments' do
        expect(scan_arguments).to eq %w[--project test.xcodeproj --targets test --clean-build]
      end
    end
  end
end
