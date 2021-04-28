abstract class Athena::Console::Input; end

class Athena::Console::Input::Argument
  @[Flags]
  enum Mode
    REQUIRED
    OPTIONAL
    IS_ARRAY
  end

  getter name : String
  getter mode : ACON::Input::Argument::Mode
  getter default : String | Array(String) | Bool | Nil
  getter description : String

  def initialize(
    @name : String,
    @mode : ACON::Input::Argument::Mode = :optional,
    @description : String = "",
    default : String | Array(String) | Bool | Nil = nil
  )
    self.default = default
  end

  def default=(default : String | Array(String) | Nil = nil)
    raise ArgumentError.new "Cannot set a default value when the argument is required." if @mode.required? && !default.nil?

    if @mode.is_array?
      if default.nil?
        default = [] of String
      else
        raise ArgumentError.new "Default value for an array argument must be an array." unless default.is_a? Array
      end
    end

    @default = default
  end

  def required? : Bool
    @mode.required?
  end

  def is_array? : Bool
    @mode.is_array?
  end
end
