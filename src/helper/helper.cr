abstract class Athena::Console::Helper; end

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

  property helper_set : ACON::Helper::HelperSet?
end
