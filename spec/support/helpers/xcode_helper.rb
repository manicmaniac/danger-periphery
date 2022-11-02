# frozen_string_literal: true

require 'rubygems/version'

module XcodeHelper
  class Version < Gem::Version
    def <=>(other)
      return super(Version.new(other.to_s)) unless other.is_a?(Version)

      super
    end
  end

  def xcode_version
    Version.new(`xcodebuild -version`.match(/^Xcode (.*)$/)[1])
  end
end
