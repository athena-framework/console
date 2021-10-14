# :nodoc:
record Athena::Console::Input::Value::Array < Athena::Console::Input::Value, value : ::Array(Athena::Console::Input::Value) do
  def self.from_array(array : ::Array) : self
    new(array.map { |item| ACON::Input::Value.from_value item })
  end

  def self.new(value)
    new [ACON::Input::Value.from_value value]
  end

  def self.new
    new [] of ACON::Input::Value
  end

  def <<(value)
    @value << ACON::Input::Value.from_value value
  end

  def get(as : ::Array(T).class) : ::Array(T) forall T
    @value.map &.get(T)
  end

  def resolve
    self.value.map &.resolve
  end

  def to_s(io : IO) : ::Nil
    @value.join io, ','
  end
end
