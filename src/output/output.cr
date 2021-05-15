require "./interface"

abstract class Athena::Console::Output
  include Athena::Console::Output::Interface

  property verbosity : ACON::Output::Verbosity
  property formatter : ACON::Formatter::Interface

  def initialize(
    verbosity : ACON::Output::Verbosity? = :normal,
    decorated : Bool = false,
    formatter : ACON::Formatter::Interface? = nil
  )
    @verbosity = verbosity || ACON::Output::Verbosity::NORMAL
    @formatter = formatter || ACON::Formatter::OutputFormatter.new decorated
  end

  def decorated? : Bool
    @formatter.decorated?
  end

  def decorated=(decorated : Bool) : Nil
    @formatter.decorated = decorated
  end

  def puts(*messages : String) : Nil
    self.puts messages
  end

  def puts(message : String | Enumerable(String), verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
    self.write message, true, verbosity, output_type
  end

  def print(*messages : String) : Nil
    self.print messages
  end

  def print(message : String | Enumerable(String), verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
    self.write message, false, verbosity, output_type
  end

  protected def write(
    message : String | Enumerable(String),
    new_line : Bool,
    verbosity : ACON::Output::Verbosity,
    output_type : ACON::Output::Type
  )
    messages = message.is_a?(String) ? {message} : message

    return if verbosity > self.verbosity

    messages.each do |message|
      self.do_write(
        case output_type
        in .normal? then @formatter.format message
        in .plain?  then @formatter.format(message).gsub(/(?:<\/?[^>]*>)|(?:<!--(.*?)-->[\n]?)/, "") # TODO: Use a more robust strip_tags implementation.
        in .raw?    then message
        end,
        new_line
      )
    end
  end

  protected abstract def do_write(message : String, new_line : Bool) : Nil
end
