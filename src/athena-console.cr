require "./application"
require "./command"
require "./terminal"

require "./commands/*"
require "./exceptions/*"
require "./input/*"
require "./formatter/*"
require "./output/*"

# Convenience alias to make referencing `Athena::Console` types easier.
alias ACON = Athena::Console

module Athena::Console
  VERSION = "0.1.0"
end

# d = ACON::Input::Definition.new
# d << ACON::Input::Argument.new "command", :required, description: "The command to execute."
# d << ACON::Input::Argument.new "id", :required
# d << ACON::Input::Option.new "dry-run", "d"
# d << ACON::Input::Option.new "foo", "f"
# d << ACON::Input::Option.new "bar", "b", :required

# input = ACON::Input::ARGVInput.new # definition: d
# new InputArgument('foo4', InputArgument::OPTIONAL | InputArgument::IS_ARRAY, '', [1, 2]),
# argument = ACON::Input::Argument.new "foo", :is_array, ["one"]

# pp argument

# new InputOption('option_name', 'o', InputOption::VALUE_IS_ARRAY | InputOption::VALUE_OPTIONAL, 'option description', []),

# pp ACON::Input::Option.new "option", "o", ACON::Input::Option::Mode::IS_ARRAY | ACON::Input::Option::Mode::OPTIONAL, "desc", Array(String).new

app = ACON::Application.new "Athena"
app.run # input, output

# console = ACON::Terminal.new
# pp console.width
# pp console.height

# @[Flags]
# enum Test
#   One
#   Two
#   Three
#   Four
# end

# e = Test::One

# pp e

# e |= Test::Four

# pp e

# e &= Test::One
# e &= Test::One

# pp e

# style = ACON::Formatter::OutputFormatterStyle.new
# style.options = ACON::Formatter::Mode::Reverse | ACON::Formatter::Mode::Hidden

# pp style

# puts style.apply "foo"
# pp style.apply "foo"

# output = Athena::Console::Output::ConsoleOutput.new

# output.puts "pre <error>Bad thing!</error> post"
# output.puts "pre <info>Something useful</info> post"
# output.puts "foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobar"
