module Athena::Console::Formatter::OutputFormatterInterface
  abstract def decorated=(@decorated : Bool)
  abstract def decorated? : Bool
  abstract def set_style(name : String, style : ACON::Formatter::OutputFormatterStyleInterface) : Nil
  abstract def has_style?(name : String) : Bool
  abstract def style(name : String) : ACON::Formatter::OutputFormatterStyleInterface
  abstract def format(message : String?) : Nil
end
