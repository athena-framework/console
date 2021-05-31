require "./application"
require "./command"
require "./cursor"
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
# input = ACON::Input::ARGV.new
# input.interactive = false
# output = ACON::Output::ConsoleOutput.new

# style = ACON::Style::Athena.new input, output

# question = ACON::Question::Choice.new "Some question", ["a", "b"]

# ACON::Helper::Question.new.ask input, output, question
# pp style.ask question
# question = ACON::Question(String?).new "Write an essay", nil
# question.multi_line = true

# pp style.ask question

# cursor = ACON::Cursor.new output
# lib LibC
#   fun wherex : LibC::Int
# end

# stty 5500:5:bf:8a3b:3:1c:7f:15:4:0:1:0:11:13:1a:0:12:f:17:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0
# cursor.move_to_position 50, 10

# pp cursor.current_position

# style.caution "Oh noes! Bad things?"
# style.error "Oh noes! Bad things?"
# style.warning "Oh noes! Bad things?"
# style.note "Oh noes! Bad things?"
# style.success "Oh noes! Bad things?"
# style.info "Oh noes! Bad things?"

# style.title "Hello from Athena!"
# style.section "Part 1"
# style.comment "Getting Started"
# style.text "foo bar baz"
# style.listing "one", "two", "three"

# pp style.ask_hidden "what is your password?"

# pp style.choice "What is your fav color?", {"Red", "Blue", "Green"}, default: "Blue"
# pp style.choice "What is your fav color?", {"r" => "Red", "g" => "Green", "b" => "Blue"}
# q = ACON::Question::MultipleChoice.new "What is your fav color?", {"Red", "Blue", "Green"}, "Red,  Green  "
# pp style.ask q
# pp q.autocompleter_values
# q = ACON::Question::Choice.new "What is your fav color?", {"r" => "Red", "g" => "Green", "b" => "Blue"}

# pp q.autocompleter_values

# pp ACON::Question::Choice.new "What is your fav color?", {"r" => "Red", "g" => "Green", "b" => "Blue"}
# question_helper = ACON::Helper::Question.new
# question = ACON::Question::Confirmation.new "Are you sure you want to do this?", false

# answer = question_helper.ask ACON::Input::ARGV.new, ACON::Output::ConsoleOutput.new, question

# pp answer, typeof(answer)

# formatter = ACON::Formatter::Output.new(true)

# output.puts formatter.format_and_wrap("Lorem <error>ipsum</error> dolor <info>sit</info> amet", 8)
