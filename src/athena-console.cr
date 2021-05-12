require "./application"
require "./command"
require "./terminal"

require "./commands/*"
require "./descriptor/*"
require "./exceptions/*"
require "./formatter/*"
require "./helper/*"
require "./input/*"
require "./loader/*"
require "./output/*"
require "./question/*"
require "./style/*"

# Convenience alias to make referencing `Athena::Console` types easier.
alias ACON = Athena::Console

module Athena::Console
  VERSION = "0.1.0"
end

ACON::Application.new("foo").run

# question_helper = ACON::Helper::Question.new
# question = ACON::Question::Confirmation.new "Are you sure you want to do this?", false

# pp question_helper.ask ACON::Input::ARGV.new, ACON::Output::ConsoleOutput.new, question
