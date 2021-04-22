require "colorize"
require "./output_formatter_style_interface"

struct Athena::Console::Formatter::OutputFormatterStyle
  # include Athena::Console::Formatter::OutputFormatterStyleInterface

  setter forground : Colorize::Color?
  setter background : Colorize::Color?
  setter options : ACON::Formatter::Mode?

  def initialize(@forground : Colorize::Color? = nil, @background : Colorize::Color? = nil, @options : ACON::Formatter::Mode? = nil)
  end

  def add_option(option : ACON::Formatter::Mode) : Nil
    @options |= option
  end

  def remove_option(option : ACON::Formatter::Mode) : Nil
    @options &= option
  end

  def apply(text : String) : String
    # TODO: Handle href's gracefully

    color = Colorize::Object(String).new text

    if fore = @forground
      color.fore fore
    end

    if back = @background
      color.back back
    end

    if options = @options
      options.each do |mode|
        color.mode mode.to_sym
      end
    end

    color.to_s
  end
end
