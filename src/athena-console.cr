require "./application"
require "./command"
require "./terminal"

require "./commands/*"
require "./descriptor/*"
require "./exceptions/*"
require "./helper/*"
require "./input/*"
require "./formatter/*"
require "./output/*"

# Convenience alias to make referencing `Athena::Console` types easier.
alias ACON = Athena::Console

module Athena::Console
  VERSION = "0.1.0"
end

class AFoo < ACON::Command
  protected def configure : Nil
    self
      .name("debug:router")
      .definition(
        ACON::Input::Argument.new("id", :optional, "The command name", "help"),
        ACON::Input::Option.new("raw", nil, :none, "To output raw command help"),
        ACON::Input::Option.new("format", nil, :required, "The output format (txt)", "txt"),
      )
      .description("Creates a new user.")
  end

  protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
    ACON::Command::Status::SUCCESS
  end
end

app = ACON::Application.new "Athena", "0.15.0"

app.add AFoo.new

app.run # input, output
