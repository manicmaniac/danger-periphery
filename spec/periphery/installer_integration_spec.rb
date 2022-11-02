# frozen_string_literal: true

describe Periphery::Installer, :slow do
  subject(:installer) { described_class.new(version_spec) }

  describe '#install' do
    # rubocop:disable RSpec/InstanceVariable
    before { @tmpdir = Dir.mktmpdir }

    after { FileUtils.rm_r(@tmpdir) }

    let(:dest_path) { File.join(@tmpdir, 'periphery') }
    # rubocop:enable RSpec/InstanceVariable

    context 'when the version is specified' do
      let(:version_spec) { '2.10.0' }

      it 'download and extract zip archive to the specified path' do
        installer.install(dest_path, force: false)
        expect(Pathname.new(dest_path)).to be_file.and be_executable
      end
    end
  end

  describe '#version' do
    context 'when :latest is specified' do
      let(:version_spec) { :latest }

      it 'returns the latest version' do
        expect(installer.version).to match(/[\d.]+/)
      end
    end
  end
end
