module Athena::Console::Output::ConsoleOutputInterface
  abstract def error_output : ACON::Output::OutputInterface
  abstract def error_output=(error_output : ACON::Output::OutputInterface)

  # abstract def section : ACON::Output::ConsoleSectionOutput
end
