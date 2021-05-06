require "./application"
require "./command"
require "./terminal"

require "./commands/*"
require "./descriptor/*"
require "./exceptions/*"
require "./helper/*"
require "./input/*"
require "./loader/*"
require "./formatter/*"
require "./output/*"

# Convenience alias to make referencing `Athena::Console` types easier.
alias ACON = Athena::Console

module Athena::Console
  VERSION = "0.1.0"
end

# require "../spec/fixtures/io_command"
# require "../spec/fixtures/*"

# app = ACON::Application.new "Athena", "0.15.0"
# app.add Foo1Command.new

# app.run # output: output
