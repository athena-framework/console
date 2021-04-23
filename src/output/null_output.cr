require "./output_interface"

class Athena::Console::Output::NullOutput
  include Athena::Console::Output::OutputInterface

  @formatter : ACON::Formatter::OutputFormatterInterface? = nil

  def puts(message : String, verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
  end

  def print(message : String, verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
  end

  def verbosity : ACON::Output::Verbosity
    :quiet
  end

  def verbosity=(verbosity : ACON::Output::Verbosity)
  end

  def decorated=(decorated : Bool)
  end

  def decorated? : Bool
    false
  end

  def formatter : ACON::Formatter::OutputFormatterInterface
    @formatter ||= ACON::Formatter::NullOutputFormatter.new
  end

  def formatter=(formatter : ACON::Formatter::OutputFormatterInterface)
  end
end
