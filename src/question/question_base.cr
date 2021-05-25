module Athena::Console::Question::QuestionBase(T)
  getter question : String
  getter default : T

  getter? hidden : Bool = false
  getter max_attempts : Int32? = nil
  getter autocompleter_callback : Proc(String, Array(String))? = nil

  property normalizer : Proc(T | String, T)? = nil

  property? multi_line : Bool = false
  property? hidden_fallback : Bool = true
  property? trimmable : Bool = true

  def initialize(@question : String, @default : T); end

  def autocompleter_values : Array(String)?
    if callback = @autocompleter_callback
      return callback.call ""
    end

    nil
  end

  def autocompleter_values=(values : Hash(String, _)?) : self
    self.autocompleter_values = values.keys + values.values
  end

  def autocompleter_values=(values : Hash?) : self
    self.autocompleter_values = values.values
  end

  def autocompleter_values=(values : Indexable?) : self
    if values.nil?
      @autocompleter_callback = nil
      return self
    end

    callback = Proc(String, Array(String)).new do
      values.to_a
    end

    self.autocompleter_callback &callback

    self
  end

  def autocompleter_callback(&block : String -> Array(String)) : Nil
    raise ACON::Exceptions::Logic.new "A hidden question cannot use the autocompleter." if @hidden

    @autocompleter_callback = block
  end

  def hidden=(hidden : Bool) : self
    raise ACON::Exceptions::Logic.new "A hidden question cannot use the autocompleter." if @autocompleter_callback

    @hidden = hidden

    self
  end

  def max_attempts=(attempts : Int32?) : self
    raise ACON::Exceptions::InvalidArgument.new "Maximum number of attempts must be a positive value." if attempts && attempts < 0

    @max_attempts = attempts
    self
  end

  protected def process_response(response : String) : T
    response = response.presence || @default

    # Only call the normalizer with the actual response or a non nil default.
    if (normalizer = @normalizer) && !response.nil?
      return normalizer.call response
    end

    return response.as T
  end
end
