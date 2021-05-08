abstract class Athena::Console::Exceptions::ConsoleException < ::Exception
  getter code : Int32

  def initialize(message : String, @code : Int32 = 0, cause : Exception? = nil)
    super message, cause
  end
end
