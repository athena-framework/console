class Athena::Console::Input::ARGVInput < Athena::Console::Input
  @tokens : Array(String)
  @parsed = Hash(String, Array(String)).new

  def initialize(@tokens : Array(String) = ARGV, definition : ACON::Input::Definition? = nil)
    super definition
  end

  protected def parse : Nil
    parse_options = true
  end
end
