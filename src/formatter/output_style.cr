require "colorize"
require "./output_formatter_style_interface"

struct Athena::Console::Formatter::OutputStyle
  include Athena::Console::Formatter::OutputStyleInterface

  setter foreground : Colorize::Color
  setter background : Colorize::Color
  setter options : ACON::Formatter::Mode = :none
  setter href : String? = nil

  getter? handles_href_gracefully : Bool do
    "JetBrains-JediTerm" != ENV["TERMINAL_EMULATOR"]? && (!ENV.has_key?("KONSOLE_VERSION") || ENV["KONSOLE_VERSION"].to_i > 201100)
  end

  def initialize(@foreground : Colorize::Color = :default, @background : Colorize::Color = :default, @options : ACON::Formatter::Mode = :none)
  end

  def add_option(option : String) : Nil
    self.add_option ACON::Formatter::Mode.parse option
  end

  def add_option(option : ACON::Formatter::Mode) : Nil
    @options |= option
  end

  def background=(color : String)
    if hex_value = color.lchop? '#'
      r, g, b = hex_value.hexbytes
      return @background = Colorize::ColorRGB.new r, g, b
    end

    @background = Colorize::ColorANSI.parse color
  end

  def foreground=(color : String)
    if hex_value = color.lchop? '#'
      r, g, b = hex_value.hexbytes
      return @foreground = Colorize::ColorRGB.new r, g, b
    end

    @foreground = Colorize::ColorANSI.parse color
  end

  def remove_option(option : String) : Nil
    self.remove_option ACON::Formatter::Mode.parse option
  end

  def remove_option(option : ACON::Formatter::Mode) : Nil
    @options &= option
  end

  def apply(text : String) : String
    if (href = @href) && self.handles_href_gracefully?
      text = "\e]8;;#{href}\e\\#{text}\e]8;;\e\\"
    end

    color = Colorize::Object(String)
      .new(text)
      .fore(@foreground)
      .back(@background)

    if options = @options
      options.each do |mode|
        color.mode mode.to_sym
      end
    end

    color.to_s
  end
end
