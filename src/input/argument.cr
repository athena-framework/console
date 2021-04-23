abstract class Athena::Console::Input; end

class Athena::Console::Input::Argument
  enum Mode
    REQUIRED
    OPTIONAL
    IS_ARRAY
  end

  getter name : String
  getter mode : ACON::Input::Argument::Mode
  getter default : String | Array(String) | Nil
  getter description : String

  def initialize(
    @name : String,
    @mode : ACON::Input::Argument::Mode = :optional,
    default : String | Array(String) | Nil = nil,
    @description : String = ""
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
end
