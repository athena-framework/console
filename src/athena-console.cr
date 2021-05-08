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

# require "./spec"
# require "../spec/fixtures/commands/io_command"
# require "../spec/fixtures/**"

# app = ACON::Application.new "foo"
# app.definition << ACON::Input::Option.new "foo", "f", :optional
# # app.add FooCommand.new
# input = ACON::Input::ARGV.new ["--foo", "bar", "-vv"]
# app.run input
