module Athena::Console::Output::ConsoleOutputInterface
  abstract def stderr : ACON::Output::OutputInterface
  abstract def stderr=(stderr : ACON::Output::OutputInterface)

  # abstract def section : ACON::Output::ConsoleSectionOutput
end
