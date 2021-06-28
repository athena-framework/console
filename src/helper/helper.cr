require "./interface"

abstract class Athena::Console::Helper
  include Athena::Console::Helper::Interface

  def self.remove_decoration(formatter : ACON::Formatter::Interface, string : String) : String
    is_decorated = formatter.decorated?
    formatter.decorated = false
    string = formatter.format string
    string = string.gsub /\033\[[^m]*m/, ""
    formatter.decorated = is_decorated

    string
  end

  # Returns the width of a string; where the width is how many character positions the string will use.
  #
  # TODO: Support double width chars.
  def self.width(string : String) : Int32
    string.size
  end

  property helper_set : ACON::Helper::HelperSet? = nil
end
