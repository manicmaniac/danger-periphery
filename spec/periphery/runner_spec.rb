# frozen_string_literal: true

require 'tempfile'

describe Periphery::Runner do
  subject(:runner) { described_class.new(executable_file.path, on_spawn: on_spawn, verbose: verbose) }

  let(:mock_periphery) { '' }
  let!(:executable_file) { Tempfile.new }
  let(:on_spawn) { nil }
  let(:verbose) { false }

  before do
    executable_file.write(mock_periphery)
    File.chmod(0o700, executable_file.path)
    executable_file.close
  end

  after { executable_file.unlink }

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
        executable_file.path,
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
      let(:mock_periphery) do
        <<~RUBY
          #!#{RbConfig.ruby}
          puts('warning:')
        RUBY
      end

      it 'returns scan result' do
        expect(scan).to include 'warning:'
      end
    end

    context 'when periphery fails' do
      let(:mock_periphery) do
        <<~RUBY
          #!#{RbConfig.ruby}
          $stderr.puts('foo')
          exit(42)
        RUBY
      end

      it 'raises an error' do
        expect { scan }.to raise_error(RuntimeError, /42.*foo/)
      end
    end

    context 'when periphery is killed by signal' do
      let(:mock_periphery) do
        <<~RUBY
          #!#{RbConfig.ruby}
          loop {}
        RUBY
      end

      let(:on_spawn) do
        ->(pid) { Process.kill('TERM', pid) }
      end

      it 'raises error with signal name' do
        expect { scan }.to raise_error(RuntimeError, /SIGTERM/)
      end
    end

    context 'when periphery executable is missing' do
      before { executable_file.unlink }

      it 'raises an error' do
        expect { scan }.to raise_error(Errno::ENOENT)
      end
    end

    context 'when verbose is true' do
      let(:verbose) { true }
      let(:mock_periphery) do
        <<~RUBY
          #!#{RbConfig.ruby}
          puts('stdout')
          $stderr.puts('stderr')
        RUBY
      end

      it 'prints stdout and stderr' do
        expect { scan }
          .to output(/stdout/).to_stdout
          .and output(/stderr/).to_stderr
      end
    end

    context 'when verbose is true and periphery fails' do
      let(:verbose) { true }
      let(:mock_periphery) do
        <<~RUBY
          #!#{RbConfig.ruby}
          puts('stdout')
          $stderr.puts('stderr')
          exit(42)
        RUBY
      end

      it 'prints stdout and stderr before raising RuntimeError' do
        expect { scan }
          .to output(/stdout/).to_stdout
          .and output(/stderr/).to_stderr
          .and raise_error(RuntimeError, /42/)
      end
    end
  end

  describe '#scan_arguments' do
    subject(:scan_arguments) { runner.scan_arguments(options) }

    let(:periphery_version) { '2.18.0' }
    let(:mock_periphery) do
      <<~RUBY
        #!#{RbConfig.ruby}
        puts(#{periphery_version.dump})
      RUBY
    end

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

      context 'with Periphery >= 2.18.0' do
        it 'returns space-separated arguments' do
          expect(scan_arguments).to eq %w[--project test.xcodeproj --targets test1 test2]
        end
      end

      context 'with Periphery < 2.18.0' do
        let(:periphery_version) { '2.17.0' }

        it 'returns comma-separated arguments' do
          expect(scan_arguments).to eq %w[--project test.xcodeproj --targets test1,test2]
        end
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

    context 'with `build_args` option' do
      let(:options) do
        {
          project: 'test.xcodeproj',
          targets: 'test',
          build_args: '-sdk iphonesimulator'
        }
      end

      it 'returns arguments with an argument terminator' do
        expect(scan_arguments).to eq ['--project', 'test.xcodeproj', '--targets', 'test', '--', '-sdk iphonesimulator']
      end
    end
  end

  describe '#version' do
    context 'when periphery succeeds' do
      let(:mock_periphery) do
        <<~RUBY
          #!#{RbConfig.ruby}
          puts('2.18.0')
        RUBY
      end

      it 'returns the correct version' do
        expect(runner.version).to eq '2.18.0'
      end
    end

    context 'when periphery fails' do
      let(:mock_periphery) do
        <<~RUBY
          #!#{RbConfig.ruby}
          $stderr.puts('error')
          exit(42)
        RUBY
      end

      it 'raises an error' do
        expect { runner.version }.to raise_error(/error/)
      end
    end

    context 'when periphery is killed by signal' do
      let(:mock_periphery) do
        <<~RUBY
          #!#{RbConfig.ruby}
          loop {}
        RUBY
      end
      let(:on_spawn) do
        ->(pid) { Process.kill('TERM', pid) }
      end

      it 'raises error with signal name' do
        expect { runner.version }.to raise_error(RuntimeError, /SIGTERM/)
      end
    end
  end
end
