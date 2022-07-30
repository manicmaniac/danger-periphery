# frozen_string_literal: true

rubocop.lint inline_comment: true

periphery.binary_path = 'bin/periphery'
periphery.scan(project: 'spec/support/fixtures/test.xcodeproj', schemes: 'test', targets: 'test') do |violation|
  !violation.message.include?('unused')
end
