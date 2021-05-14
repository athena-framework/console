module Athena::Console::Output::Interface
  abstract def puts(message : String | Enumerable(String), verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
  abstract def print(message : String | Enumerable(String), verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
  abstract def verbosity : ACON::Output::Verbosity
  abstract def verbosity=(verbosity : ACON::Output::Verbosity)
  abstract def decorated=(decorated : Bool)
  abstract def decorated? : Bool
  abstract def formatter : ACON::Formatter::Interface
  abstract def formatter=(formatter : ACON::Formatter::Interface)
end
