# frozen_string_literal: true

describe Periphery::Installer do
  subject(:installer) { described_class.new(version_spec) }

  before do
    uri = instance_double(OpenURI::OpenRead)
    allow(uri).to receive(:open).and_yield File.binread(fixture('periphery.zip'))
    allow(URI).to receive(:parse).and_call_original
    allow(URI).to receive(:parse).with(match %r{^https://github\.com/.*\.zip$}).and_return uri
    response = instance_double(Net::HTTPResponse)
    allow(response).to receive(:[]).with('location').and_return 'https://github.com/peripheryapp/periphery/tags/100.0.0'
    http = instance_double(Net::HTTP)
    allow(http).to receive(:head).with('/peripheryapp/periphery/releases/latest').and_return response
    allow(Net::HTTP).to receive(:start).with('github.com', port: 443, use_ssl: true).and_yield http
  end

  describe '#install' do
    # rubocop:disable RSpec/InstanceVariable
    before { @tmpdir = Dir.mktmpdir }

    after { FileUtils.rm_r(@tmpdir) }

    let(:dest_path) { File.join(@tmpdir, 'periphery') }
    # rubocop:enable RSpec/InstanceVariable

    let(:version_spec) { '1.0.0' }

    context 'when force install is not specified' do
      it 'download and extract zip archive to the specified path' do
        installer.install(dest_path, force: false)
        expect(Pathname.new(dest_path)).to be_file.and be_executable
      end
    end

    context 'when force install is specified' do
      before { FileUtils.touch(dest_path) }

      it 'download and extract zip archive to the specified path with deleting the existing file' do
        installer.install(dest_path, force: true)
        expect(Pathname.new(dest_path)).to be_file.and be_executable
      end
    end
  end

  describe '#version' do
    context 'when :latest is specified' do
      let(:version_spec) { :latest }

      it 'returns the latest version' do
        expect(installer.version).to eq '100.0.0'
      end
    end

    context 'when version is specified' do
      let(:version_spec) { '1.0.0' }

      it 'returns the specified version as-is' do
        expect(installer.version).to eq '1.0.0'
      end
    end
  end
end
