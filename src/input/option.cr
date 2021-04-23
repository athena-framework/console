class Athena::Console::Input::Option
  @[Flags]
  enum Mode
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
  getter shortcut : String | Array(String) | Nil
  getter mode : ACON::Input::Option::Mode
  getter default : String | Array(String) | Bool | Nil
  getter description : String

  def initialize(
    name : String,
    shortcut : String | Array(String) | Nil = nil,
    @mode : ACON::Input::Option::Mode = :none,
    @description : String = "",
    default : String | Array(String) | Bool | Nil = nil
  )
    @name = name.lchop "--"

    raise ArgumentError.new " An option name cannot be blank." if name.blank?

    if shortcut.nil?
      if shortcut.is_a? Array
        shortcut = shortcut.join '|'
      end

      raise ArgumentError.new "An option shortcut cannot be empty." if shortcut.nil?
    end

    @shortcut = shortcut

    if @mode.is_array? && !@mode.accepts_value?
      raise ArgumentError.new " Cannot have IS_ARRAY option mode when the option does not accept a value."
    end

    if @mode.negatable? && @mode.accepts_value?
      raise ArgumentError.new " Cannot have NEGATABLE option mode if the option also accepts a value."
    end

    self.default = default
  end

  def default=(default : String | Array(String) | Bool | Nil) : Nil
    raise ArgumentError.new "Cannot set a default value when the argument is required." if @mode.required? && !default.nil?
    raise ArgumentError.new "Cannot set a default value when using NEGATABLE mode." if @mode.negatable? && !default.nil?

    if @mode.is_array?
      if default.nil?
        default = [] of String
      else
        raise ArgumentError.new "Default value for an array argument must be an array." unless default.is_a? Array
      end
    end

    @default = @mode.accepts_value? ? default : false
  end
end
