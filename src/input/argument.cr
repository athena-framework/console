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
  @default : AbstractValue? = nil
  getter description : String

  def initialize(
    @name : String,
    @mode : ACON::Input::Argument::Mode = :optional,
    @description : String = "",
    default = nil
  )
    raise ACON::Exceptions::InvalidArgument.new "An argument name cannot be blank." if name.blank?

    self.default = default
  end

  def default
    @default.try do |value|
      case value
      when ArrayValue
        value.value.map &.value
      else
        value.value
      end
    end
  end

  def default(as : T.class) : T forall T
    @default.not_nil!.get T
  end

  def default=(default = nil)
    raise ACON::Exceptions::Logic.new "Cannot set a default value when the argument is required." if @mode.required? && !default.nil?

    if @mode.is_array?
      if default.nil?
        return @default = ArrayValue.new
      elsif !default.is_a? Array
        raise ACON::Exceptions::Logic.new "Default value for an array argument must be an array."
      end
    end

    @default = AbstractValue.from_value default
  end

  def required? : Bool
    @mode.required?
  end

  def is_array? : Bool
    @mode.is_array?
  end
end
