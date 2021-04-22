require "semantic_version"

abstract class Athena::Console::Applicaiton
  @terminal : ACON::Terminal
  @version : SemanticVersion
  @default_command : String = "list"

  def self.new(name : String = "UNKNOWN", version : String = "0.1.0") : self
    new name, SemanticVersion.parse version
  end

  def initialize(@name : String = "UNKNOWN", @version : SemanticVersion = SemanticVersion.new(0, 1, 0))
    @terminal = ACON::Terminal.new

    # TODO: Emit events when certain signals are triggered.
    # This'll require the ability to optionall set an event dispatcher on this type.
  end

  def run(input : IO = ARGV, output : IO = STDOUT) : ACON::Command::Status
    ENV["LINES"] = @terminal.height.to_s
    ENV["COLUMNS"] = @terminal.width.to_s

    # TODO: What to do about error handling?

    self.configure_io input, output

    begin
      exit_status = self.do_run input, output
    rescue ex : Exception
      exit_status = :failure
    end

    exit_status
  end

  def do_run(input : IO = ARGV, output : IO = STDOUT) : ACON::Command::Status
    :success
  end
end
