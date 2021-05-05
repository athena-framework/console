module Athena::Console::Loader::Interface
  abstract def get(name : String) : ACON::Command
  abstract def has?(name : String) : Bool
  abstract def names : Array(String)
end
