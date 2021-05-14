class Athena::Console::Question(T)
  getter question : String
  getter default : T

  getter? hidden : Bool = false
  getter max_attempts : Int32? = nil
  getter autocompleter : Proc(String, Array(String))? = nil

  property normalizer : Proc(T | String, T)? = nil
  property validator : Proc(T, T)? = nil

  property? multi_line : Bool = false
  property? hidden_fallback : Bool = true
  property? trimmable : Bool = true

  def initialize(@question : String, @default : T); end

  def autocompleter=(callback : Proc(String, Array(String))) : Nil
    raise ACON::Exceptions::Logic.new "A hidden question cannot use the autocompleter." if @hidden && !callback.nil?

    @autocompleter = callback
  end

  def hidden=(hidden : Bool) : Nil
    raise ACON::Exceptions::Logic.new "A hidden question cannot use the autocompleter." if @autocompleter

    @hidden = hidden
  end

  protected def process_response(response : String) : T?
    response = response.presence || @default

    # Only call the normalizer with the actual response or a non nil default.
    if (normalizer = @normalizer) && !response.nil?
      return normalizer.call response
    end

    return response
  end
end
