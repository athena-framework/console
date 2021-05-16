require "./interface"

module Athena::Console::Formatter::WrappableInterface
  include Athena::Console::Formatter::Interface

  abstract def format_and_wrap(message : String?, width : Int32) : String
end