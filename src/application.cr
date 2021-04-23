require "semantic_version"

abstract class Athena::Console::Application
  @terminal : ACON::Terminal
  @version : SemanticVersion
  @default_command : String = "list"

  def self.new(name : String = "UNKNOWN", version : String = "0.1.0") : self
    new name, SemanticVersion.parse version
  end

  def initialize(@name : String = "UNKNOWN", @version : SemanticVersion = SemanticVersion.new(0, 1, 0))
    @terminal = ACON::Terminal.new

    # TODO: Emit events when certain signals are triggered.
    # This'll require the ability to optional set an event dispatcher on this type.
  end

  def run(input : IO = ARGV, output : ACON::Output::OutputInterface? = nil) : ACON::Command::Status
    ENV["LINES"] = @terminal.height.to_s
    ENV["COLUMNS"] = @terminal.width.to_s

    output = output || ACON::Output::ConsoleOutput.new

    # TODO: What to do about error handling?

    self.configure_io input, output

    begin
      exit_status = self.do_run input, output
    rescue ex : Exception
      exit_status = :failure
    end

    exit_status
  end

  def do_run(input : IO, output : ACON::Output::OutputInterface) : ACON::Command::Status
    :success
  end

  protected def configure_io(input : IO, output : ACON::Output::OutputInterface) : Nil
    case shell_verbosity = ENV["SHELL_VERBOSITY"]?.try &.to_i
    when -1 then output.verbosity = :quiet
    when  1 then output.verbosity = :verbose
    when  2 then output.verbosity = :very_verbose
    when  3 then output.verbosity = :debug
    else
      shell_verbosity = 0
    end

    if shell_verbosity.quiet?
      # input.interactive = false
    end

    ENV["SHELL_VERBOSITY"] = shell_verbosity.to_s
  end
end
