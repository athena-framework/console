# :nodoc:
record Athena::Console::Input::Value::Number < Athena::Console::Input::Value, value : ::Number::Primitive do
  {% for type in ::Number::Primitive.union_types %}
    def get(as : {{type.id}}.class) : {{type.id}}
      {{type.id}}.new @value
    end
  {% end %}
end
