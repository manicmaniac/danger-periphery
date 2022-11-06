# frozen_string_literal: true

rubocop.lint inline_comment: true

DANGER_FILE = self

module ::Danger
  class PluginLint # :nodoc:
    def abort(*_args); end
  end

  class PluginLinter # :nodoc:
    def print_summary(*_args)
      do_rules(DANGER_FILE.method(:fail), errors)
      do_rules(DANGER_FILE.method(:warn), warnings)
    end

    def do_rules(method, rules)
      rules.each do |rule|
        abs_file, line = rule.metadata[:files][0]
        file = Pathname.new(abs_file).relative_path_from(Dir.pwd).to_s
        method.call(rule.description, file: file, line: line)
      end
    end
  end
end

Danger::PluginLint.new(CLAide::ARGV.new([])).run

periphery.binary_path = 'bin/periphery'
periphery.scan(project: 'spec/support/fixtures/test.xcodeproj', schemes: 'test', targets: 'test') do |violation|
  !violation.message.include?('unused')
end
