require "colorize"
require "./mode"

module Athena::Console::Formatter::OutputFormatterStyleInterface
  abstract def foreground=(forground : Colorize::Color)
  abstract def background=(background : Colorize::Color)
  abstract def add_option(option : ACON::Formatter::Mode) : Nil
  abstract def remove_option(option : ACON::Formatter::Mode) : Nil

  abstract def apply(text : String) : String
end
