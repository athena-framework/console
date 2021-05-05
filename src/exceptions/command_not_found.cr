require "./console_exception"

class Athena::Console::Exceptions::CommandNotFound < Athena::Console::Exceptions::ConsoleException
  getter alternatives : Array(String)

  def initialize(message : String, @alternatives : Array(String) = [] of String, cause : Exception? = nil)
    super message, cause
  end
end
