require "./interface"

class Athena::Console::Formatter::NullFormatter
  include Athena::Console::Formatter::Interface

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
    @style ||= ACON::Formatter::NullFormatterStyle.new
  end

  def format(message : String?) : String
    message
  end
end
