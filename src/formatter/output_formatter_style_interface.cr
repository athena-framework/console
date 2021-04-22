require "colorize"
require "./mode"

module Athena::Console::Formatter::OutputFormatterStyleInterface
  abstract def foreground=(color : Colorize::Color) : Nil
  abstract def background=(color : Colorize::Color) : Nil
  abstract def add_option(option : ACON::Formatter::Mode) : Nil
  abstract def remove_option(option : ACON::Formatter::Mode) : Nil

  abstract def apply(text : String) : String
end
