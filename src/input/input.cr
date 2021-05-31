require "./interface"
require "./streamable"

abstract class Athena::Console::Input
  include Athena::Console::Input::Streamable

  alias InputTypes = String | Bool | Nil | Number::Primitive
  alias InputType = InputTypes | Array(InputTypes)
  alias HashType = ::Hash(String, InputType)

  property stream : IO? = nil

  property? interactive : Bool = true

  @arguments = HashType.new
  @definition : ACON::Input::Definition
  @options = HashType.new

  def initialize(definition : ACON::Input::Definition? = nil)
    if definition.nil?
      @definition = ACON::Input::Definition.new
    else
      @definition = definition
      self.bind definition
      self.validate
    end
  end

  def argument(name : String)
    raise ACON::Exceptions::InvalidArgument.new "The '#{name}' argument does not exist." unless @definition.has_argument? name

    if @arguments.has_key? name
      return @arguments[name]
    end

    @definition.argument(name).default
  end

  def argument(name : String, type : T.class) : T forall T
    self.argument(name).as T
  end

  def set_argument(name : String, value : String | Array(String) | Nil) : Nil
    raise ACON::Exceptions::InvalidArgument.new "The '#{name}' argument does not exist." unless @definition.has_argument? name

    @arguments[name] = value
  end

  def arguments : ::Hash
    @definition.argument_defaults.merge @arguments
  end

  def has_argument?(name : String) : Bool
    @definition.has_argument? name
  end

  def option(name : String)
    raise ACON::Exceptions::InvalidArgument.new "The '#{name}' option does not exist." unless @definition.has_option? name

    if @options.has_key? name
      return @options[name]
    end

    @definition.option(name).default
  end

  def option(name : String, type : T.class) : T forall T
    self.option(name).as T
  end

  def set_option(name : String, value : String | Array(String) | Bool | Nil) : Nil
    raise ACON::Exceptions::InvalidArgument.new "The '#{name}' option does not exist." unless @definition.has_option? name

    @options[name] = value
  end

  def options : ::Hash
    @definition.option_defaults.merge @options
  end

  def has_option?(name : String) : Bool
    @definition.has_option? name
  end

  def bind(definition : ACON::Input::Definition) : Nil
    @arguments.clear
    @options.clear
    @definition = definition

    self.parse
  end

  protected abstract def parse : Nil

  def validate : Nil
    missing_args = @definition.arguments.keys.select do |arg|
      !@arguments.has_key?(arg) && @definition.argument(arg).required?
    end

    raise ACON::Exceptions::ValidationFailed.new %(Not enough arguments (missing: '#{missing_args.join(", ")}').) unless missing_args.empty?
  end
end
