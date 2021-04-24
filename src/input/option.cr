class Athena::Console::Input::Option
  @[Flags]
  enum Value
    NONE
    REQUIRED
    OPTIONAL
    IS_ARRAY
    NEGATABLE

    def accepts_value? : Bool
      self.required? || self.optional?
    end
  end

  getter name : String
  getter shortcut : String?
  getter value_mode : ACON::Input::Option::Value
  getter default : String | Array(String) | Bool | Nil
  getter description : String

  def initialize(
    name : String,
    shortcut : String | Array(String) | Nil = nil,
    @value_mode : ACON::Input::Option::Value = :none,
    @description : String = "",
    default : String | Array(String) | Bool | Nil = nil
  )
    @name = name.lchop "--"

    raise ArgumentError.new " An option name cannot be blank." if name.blank?

    unless shortcut.nil?
      if shortcut.is_a? Array
        shortcut = shortcut.join '|'
      end

      raise ArgumentError.new "An option shortcut cannot be empty." if shortcut.nil?
    end

    @shortcut = shortcut

    if @value_mode.is_array? && !self.accepts_value?
      raise ArgumentError.new " Cannot have IS_ARRAY option mode when the option does not accept a value."
    end

    if @value_mode.negatable? && self.accepts_value?
      raise ArgumentError.new " Cannot have NEGATABLE option mode if the option also accepts a value."
    end

    self.default = default
  end

  def default=(default : String | Array(String) | Bool | Nil) : Nil
    raise ArgumentError.new "Cannot set a default value when the argument is required." if @value_mode.required? && !default.nil?
    raise ArgumentError.new "Cannot set a default value when using NEGATABLE mode." if @value_mode.negatable? && !default.nil?

    if @value_mode.is_array?
      if default.nil?
        default = [] of String
      else
        raise ArgumentError.new "Default value for an array argument must be an array." unless default.is_a? Array
      end
    end

    @default = @value_mode.accepts_value? ? default : false
  end

  def accepts_value? : Bool
    @value_mode.accepts_value?
  end

  def is_array? : Bool
    @value_mode.is_array?
  end

  def value_required? : Bool
    @value_mode.required?
  end

  def value_optional? : Bool
    @value_mode.optional?
  end
end
