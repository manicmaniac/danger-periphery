# frozen_string_literal: true

rubocop.lint inline_comment: true

periphery.binary_path = "bin/periphery"
periphery.process_warnings do |path, line, column, message|
  !message.match(/unused/i)
end

periphery.scan(
  project: "spec/support/fixtures/test.xcodeproj",
  schemes: "test",
  targets: "test"
)
