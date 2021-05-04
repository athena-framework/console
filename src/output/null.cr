require "./interface"

class Athena::Console::Output::Null
  include Athena::Console::Output::Interface

  @formatter : ACON::Formatter::Interface? = nil

  def puts(message, verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
  end

  def print(message, verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
  end

  def verbosity : ACON::Output::Verbosity
    ACON::Output::Verbosity::QUIET
  end

  def verbosity=(verbosity : ACON::Output::Verbosity)
  end

  def decorated=(decorated : Bool)
  end

  def decorated? : Bool
    false
  end

  def formatter : ACON::Formatter::Interface
    @formatter ||= ACON::Formatter::NullFormatter.new
  end

  def formatter=(formatter : ACON::Formatter::Interface)
  end
end
