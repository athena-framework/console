abstract class Athena::Console::Output; end

require "./console_output_interface"
require "./io_output"

class Athena::Console::Output::ConsoleOutput < Athena::Console::Output::IOOutput
  include Athena::Console::Output::ConsoleOutputInterface

  property stderr : ACON::Output::OutputInterface

  def initialize(
    verbosity : ACON::Output::Verbosity = :normal,
    decorated : Bool? = nil,
    formatter : ACON::Formatter::OutputFormatterInterface? = nil
  )
    super STDOUT, verbosity, decorated, formatter

    @stderr = ACON::Output::IOOutput.new STDERR, verbosity, decorated, @formatter
    actual_decorated = self.decorated?

    if decorated.nil?
      self.decorated = actual_decorated && @stderr.decorated?
    end
  end

  # TODO: Support sections

  def decorated=(decorated : Bool)
    super
    @stderr.decorated = decorated
  end

  def formatter=(formatter : Bool)
    super
    @stderr.formatter = formatter
  end

  def verbosity=(verbosity : Bool)
    super
    @stderr.verbosity = verbosity
  end
end