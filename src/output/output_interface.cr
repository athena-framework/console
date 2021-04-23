module Athena::Console::Output::OutputInterface
  abstract def puts(message : String, verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
  abstract def print(message : String, verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
  abstract def verbosity : ACON::Output::Verbosity
  abstract def verbosity=(verbosity : ACON::Output::Verbosity)
  abstract def decorated=(decorated : Bool)
  abstract def decorated? : Bool
  abstract def formatter : ACON::Formatter::OutputFormatterInterface
  abstract def formatter=(formatter : ACON::Formatter::OutputFormatterInterface)
end
