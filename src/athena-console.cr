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

# ACON::Application.new("foo").run

input = ACON::Input::ARGV.new
output = ACON::Output::ConsoleOutput.new

style = ACON::Style::Athena.new input, output

style.caution "Oh noes! Bad things?"
style.error "Oh noes! Bad things?"
style.warning "Oh noes! Bad things?"
style.note "Oh noes! Bad things?"
style.success "Oh noes! Bad things?"
style.info "Oh noes! Bad things?"

# question_helper = ACON::Helper::Question.new
# question = ACON::Question::Confirmation.new "Are you sure you want to do this?", false

# answer = question_helper.ask ACON::Input::ARGV.new, ACON::Output::ConsoleOutput.new, question

# pp answer, typeof(answer)
