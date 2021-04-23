require "./application"
require "./command"
require "./terminal"

require "./commands/*"
require "./formatter/*"
require "./output/*"

# Convenience alias to make referencing `Athena::Console` types easier.
alias ACON = Athena::Console

module Athena::Console
  VERSION = "0.1.0"
end

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

output = Athena::Console::Output::ConsoleOutput.new

output.puts "pre <error>Bad thing!</error> post"
output.puts "pre <info>Something useful</info> post"
output.puts output.formatter.format_and_wrap "foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobar", 35
