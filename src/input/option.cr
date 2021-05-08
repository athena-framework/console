class Athena::Console::Input::Option
  @[Flags]
  enum Value
    NONE      = 0
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

  def_equals @name, @shortcut, @default, @value_mode

  def initialize(
    name : String,
    shortcut : String | Array(String) | Nil = nil,
    @value_mode : ACON::Input::Option::Value = :none,
    @description : String = "",
    default : String | Array(String) | Bool | Nil = nil
  )
    @name = name.lchop "--"

    raise ACON::Exceptions::InvalidArgument.new "An option name cannot be blank." if name.blank?

    unless shortcut.nil?
      if shortcut.is_a? Array
        shortcut = shortcut.join '|'
      end

      shortcut = shortcut.lchop('-').split(/(?:\|)-?/, remove_empty: true).map(&.strip.lchop('-')).join '|'

      raise ACON::Exceptions::InvalidArgument.new "An option shortcut cannot be blank." if shortcut.blank?
    end

    @shortcut = shortcut

    if @value_mode.is_array? && !self.accepts_value?
      raise ACON::Exceptions::InvalidArgument.new " Cannot have VALUE::IS_ARRAY option mode when the option does not accept a value."
    end

    if @value_mode.negatable? && self.accepts_value?
      raise ACON::Exceptions::InvalidArgument.new " Cannot have VALUE::NEGATABLE option mode if the option also accepts a value."
    end

    self.default = default
  end

  def default=(default : String | Array(String) | Bool | Nil) : Nil
    raise ACON::Exceptions::Logic.new "Cannot set a default value when using Value::NONE mode." if @value_mode.none? && !default.nil?

    if @value_mode.is_array?
      if default.nil?
        default = [] of String
      else
        raise ACON::Exceptions::Logic.new "Default value for an array option must be an array." unless default.is_a? Array
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

  def negatable? : Bool
    @value_mode.negatable?
  end

  def value_required? : Bool
    @value_mode.required?
  end

  def value_optional? : Bool
    @value_mode.optional?
  end
end
