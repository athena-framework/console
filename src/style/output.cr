require "./interface"

abstract class Athena::Console::Style::Output
  include Athena::Console::Style::Interface
  include Athena::Console::Output::Interface

  @output : ACON::Output::Interface

  def initialize(@output : ACON::Output::Interface); end

  def decorated? : Bool
    @output.decorated?
  end

  def decorated=(decorated : Bool) : Nil
    @output.decorated = decorated
  end

  def formatter : ACON::Formatter::Interface
    @output.formatter
  end

  def formatter=(formatter : ACON::Formatter::Interface)
    @output.formatter = formatter
  end

  def new_line(count : Int32 = 1) : Nil
    @output.print "\n" * count
  end

  def puts(message : String | Enumerable(String), verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
    @output.puts message, verbosity, output_type
  end

  def print(message : String | Enumerable(String), verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
    @output.print message, verbosity, output_type
  end

  def verbosity : ACON::Output::Verbosity
    @output.verbosity
  end

  def verbosity=(verbosity : ACON::Output::Verbosity)
    @output.verbosity = verbosity
  end
end
