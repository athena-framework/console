module Athena::Console::Output::ConsoleOutputInterface
  abstract def error_output : ACON::Output::Interface
  abstract def error_output=(error_output : ACON::Output::Interface)
  abstract def section : ACON::Output::Section
end
