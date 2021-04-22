require "./output_formatter_interface"

module Athena::Console::Formatter::WrappableOutputFormatterInterface
  include Athena::Console::Formatter::OutputFormatterInterface

  abstract def format_and_wrap(message : String?, width : Int32?) : String
end
