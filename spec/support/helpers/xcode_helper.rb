# frozen_string_literal: true

require 'rubygems/version'

module XcodeHelper
  class Version < Gem::Version
    def <=>(other)
      return super(Version.new(other.to_s)) unless other.is_a?(Version)

      super
    end
  end

  def index_store_path_for(derived_data_path)
    index_dir = xcode_version >= 14 ? 'Index.noindex' : 'Index'
    File.join(derived_data_path, index_dir, 'DataStore')
  end

  def xcode_version
    Version.new(`xcodebuild -version`.match(/^Xcode (.*)$/)[1])
  end
end
