# frozen_string_literal: true

shared_context 'when test.xcodeproj is indexed' do
  include XcodeHelper

  # rubocop:disable RSpec/InstanceVariable
  let(:index_store_path) { index_store_path_for @derived_data_path }

  before :all do
    @derived_data_path = Dir.mktmpdir
    system('xcodebuild', 'build-for-testing', '-quiet',
           '-project', fixture('test.xcodeproj'),
           '-scheme', 'test',
           '-configuration', 'Debug',
           '-destination', 'platform=macOS',
           '-derivedDataPath', @derived_data_path)
  end

  after(:all) { FileUtils.rm_r(@derived_data_path) }
  # rubocop:enable RSpec/InstanceVariable
end
