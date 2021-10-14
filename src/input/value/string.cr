# :nodoc:
struct Athena::Console::Input::Value::String < Athena::Console::Input::Value
  getter value : ::String

  def initialize(@value : ::String); end

  def get(as : ::Bool.class) : ::Bool
    @value == "true"
  end

  def get(as : ::Bool?.class) : ::Bool?
    (@value == "true").try do |v|
      return v
    end

    nil
  end

  {% for type in ::Number::Primitive.union_types %}  
    def get(as : {{type.id}}.class) : {{type.id}}
      {{type.id}}.new @value
    rescue ArgumentError
      raise "'#{@value}' is not a valid '#{{{type.id}}}'."
    end
    
    def get(as : {{type.id}}?.class) : {{type.id}}?
      {{type.id}}.new(@value) || nil
    rescue ArgumentError
      raise "'#{@value}' is not a valid '#{{{type.id}}}'."
    end
  {% end %}
end
