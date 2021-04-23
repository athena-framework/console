require "./output_formatter_interface"

class Athena::Console::Formatter::NullOutputFormatter
  include Athena::Console::Formatter::OutputFormatterInterface

  @style : ACON::Formatter::OutputFormatterStyle? = nil

  def decorated=(@decorated : Bool)
  end

  def decorated? : Bool
    false
  end

  def set_style(name : String, style : ACON::Formatter::OutputFormatterStyleInterface) : Nil
  end

  def has_style?(name : String) : Bool
    false
  end

  def style(name : String) : ACON::Formatter::OutputFormatterStyleInterface
    @style ||= ACON::Formatter::NullOutputFormatterStyle.new
  end

  def format(message : String?) : String
    message
  end
end
