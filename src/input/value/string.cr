# :nodoc:
struct Athena::Console::Input::Value::String < Athena::Console::Input::Value
  getter value : ::String

  def initialize(@value : ::String); end

  def get(as : ::Bool.class) : ::Bool
    raise ACON::Exceptions::Logic.new "'#{@value}' is not a valid 'Bool'." unless @value.in? "true", "false"

    @value == "true"
  end

  def get(as : ::Bool?.class) : ::Bool?
    (@value == "true").try do |v|
      raise ACON::Exceptions::Logic.new "'#{@value}' is not a valid 'Bool?'." unless @value.in? "true", "false"
      return v
    end

    nil
  end

  def get(as : ::Array(T).class) : ::Array(T) forall T
    Array.from_array(@value.split(',')).get ::Array(T)
  end

  def get(as : ::Array(T)?.class) : ::Array(T)? forall T
    Array.from_array(@value.split(',')).get ::Array(T)?
  end

  {% for type in ::Number::Primitive.union_types %}
    def get(as : {{type.id}}.class) : {{type.id}}
      {{type.id}}.new @value
    rescue ArgumentError
      raise ACON::Exceptions::Logic.new "'#{@value}' is not a valid '#{{{type.id}}}'."
    end

    def get(as : {{type.id}}?.class) : {{type.id}}?
      {{type.id}}.new(@value) || nil
    rescue ArgumentError
      raise ACON::Exceptions::Logic.new "'#{@value}' is not a valid '#{{{type.id}}}'."
    end
  {% end %}
end
