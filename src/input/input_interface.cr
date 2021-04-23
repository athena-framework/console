require "./definition"

module Athena::Console::Input::InputInterface
  # abstract def first_argument : String?
  # abstract def has_parameter?(name : String, only_params : Bool) : Bool
  # abstract def parameter(name : String, default : _, only_params : Bool)
  # abstract def bind(definition : ACON::Input::Definition) : Nil
  # abstract def validate : Nil
  # abstract def arguments : Array(String)
  # abstract def argument(name : String) : String | Array(String) | Nil
  # abstract def set_argument(name : String, value : String | Array(String) | Nil) : Nil
  # abstract def options
  # abstract def option(name : String) : String | Array(String) | Bool | Nil
  # abstract def set_option(name : String, value : String | Array(String) | Bool | Nil) : Nil
  # abstract def has_option?(name : String) : Bool
  # abstract def interactive? : Bool
  # abstract def interactive=(interactive : Bool)
end
