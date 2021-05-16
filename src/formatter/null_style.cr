class Athena::Console::Formatter::NullStyle
  include Athena::Console::Formatter::OutputStyleInterface

  def foreground=(forground : Colorize::Color)
  end

  def background=(background : Colorize::Color)
  end

  def add_option(option : ACON::Formatter::Mode) : Nil
  end

  def remove_option(option : ACON::Formatter::Mode) : Nil
  end

  def apply(text : String) : String
    text
  end
end
