# frozen_string_literal: true

module ::Guard
  class Periphery < Plugin
    def initialize(options = {})
      opts = options.dup
      @command = [
        "bin/periphery",
        "scan",
        "--project",
        opts.delete(:project),
        "--targets",
        opts.delete(:targets),
        "--schemes",
        opts.delete(:schemes),
        "--format",
        "checkstyle"
      ]
      super(opts)
    end

    def run_all
      UI.info(@command.shelljoin)
      system(*@command)
    end

    def run_on_changes(_paths)
      run_all
    end
  end
end

guard :rspec, cmd: "bundle exec rspec -t ~slow", run_all: { cmd: "bundle exec rspec" } do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)
end

guard :periphery, project: "spec/support/fixtures/test.xcodeproj", targets: "test", schemes: "test" do
  watch("spec/support/fixtures/test/main.swift")
end
