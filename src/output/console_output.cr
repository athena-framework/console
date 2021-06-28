abstract class Athena::Console::Output; end

require "./console_output_interface"
require "./io"

class Athena::Console::Output::ConsoleOutput < Athena::Console::Output::IO
  include Athena::Console::Output::ConsoleOutputInterface

  setter stderr : ACON::Output::Interface
  @console_section_outputs = Array(ACON::Output::Section).new

  def initialize(
    verbosity : ACON::Output::Verbosity = :normal,
    decorated : Bool? = nil,
    formatter : ACON::Formatter::Interface? = nil
  )
    super STDOUT, verbosity, decorated, formatter

    @stderr = ACON::Output::IO.new STDERR, verbosity, decorated, @formatter
    actual_decorated = self.decorated?

    if decorated.nil?
      self.decorated = actual_decorated && @stderr.decorated?
    end
  end

  def section : ACON::Output::Section
    ACON::Output::Section.new(
      self.io,
      @console_section_outputs,
      self.verbosity,
      self.decorated?,
      self.formatter
    )
  end

  def error_output : ACON::Output::Interface
    @stderr
  end

  def error_output=(error_output : ACON::Output::Interface)
    @stderr = error_output
  end

  def decorated=(decorated : Bool)
    super
    @stderr.decorated = decorated
  end

  def formatter=(formatter : Bool)
    super
    @stderr.formatter = formatter
  end

  def verbosity=(verbosity : ACON::Output::Verbosity)
    super
    @stderr.verbosity = verbosity
  end
end
