# :nodoc:
record Athena::Console::Input::Value::String < Athena::Console::Input::Value, value : ::String do
  def get(as : ::Bool.class) : ::Bool
    @value == "true"
  end

  {% for type in ::Number::Primitive.union_types %}
    def get(as : {{type.id}}.class) : {{type.id}}
      {{type.id}}.new @value
    end

    def get(as : {{type.id}}?.class) : {{type.id}}?
      self.get {{type.id}}
    end
  {% end %}
end
