require "./wrappable_output_formatter_interface"

class Athena::Console::Formatter::OutputFormatter
  # include Athena::Console::Formatter::WrappableOutputFormatterInterface

  @styles = Hash(String, ACON::Formatter::OutputFormatterStyleInterface).new

  # :inherit:
  property? decorated : Bool

  def initialize(@decorated : Bool = false, styles : ACON::Formatter::Mode? = nil)
  end

  def set_style(name : String, style : ACON::Formatter::OutputFormatterStyleInterface) : Nil
    @styles[name.downcase] = style
  end

  def has_style?(name : String) : Bool
    @styles.has_key? name.downcase
  end

  def style(name : String) : ACON::Formatter::OutputFormatterStyleInterface
    @styles[name.downcase]
  end
end
