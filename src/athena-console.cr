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
# app.auto_exit = false
# ENV["COLUMNS"] = "22"
# app.add(ACON::Spec::MockCommand.new "foo" do
#   raise "dont break here <info>!</info>"
# end)

# app.run
