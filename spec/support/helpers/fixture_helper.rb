# frozen_string_literal: true

require 'pathname'

module FixtureHelper
  def fixtures_path
    Pathname.new('../fixtures').expand_path(__dir__)
  end

  def fixture(filename)
    fixtures_path.join(filename).to_s
  end

  def binaries_path
    Pathname.new('../../../bin').expand_path(__dir__)
  end

  def binary(filename)
    binaries_path.join(filename).to_s
  end
end
