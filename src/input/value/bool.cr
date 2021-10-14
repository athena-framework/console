# :nodoc:
record Athena::Console::Input::Value::Bool < Athena::Console::Input::Value, value : ::Bool do
  def get(as : ::Bool.class) : ::Bool
    @value
  end
end
