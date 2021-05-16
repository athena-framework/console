require "./output_style_interface"

module Athena::Console::Formatter::Interface
  abstract def decorated=(@decorated : Bool)
  abstract def decorated? : Bool
  abstract def set_style(name : String, style : ACON::Formatter::OutputStyleInterface) : Nil
  abstract def has_style?(name : String) : Bool
  abstract def style(name : String) : ACON::Formatter::OutputStyleInterface
  abstract def format(message : String?) : String
end
