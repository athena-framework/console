require "./interface"

abstract class Athena::Console::Input
  include Athena::Console::Input::Interface

  alias InputTypes = String | Bool | Nil
  alias InputType = InputTypes | Array(InputTypes)
  alias HashType = ::Hash(String, InputType)

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
    raise "The #{name} argument does not exist." unless @definition.has_argument? name

    @arguments[name]? || @definition.argument(name).default
  end

  def argument(name : String, type : T.class) : T forall T
    self.argument(name).as T
  end

  def arguments : ::Hash
    @definition.argument_defaults.merge @arguments
  end

  def option(name : String)
    raise "The #{name} option does not exist." unless @definition.has_option? name

    @options[name]? || @definition.option(name).default
  end

  def option(name : String, type : T.class) : T forall T
    self.option(name).as T
  end

  def options : ::Hash
    @definition.option_defaults.merge @options
  end

  def bind(definition : ACON::Input::Definition) : Nil
    @arguments.clear
    @options.clear
    @definition = definition

    self.parse
  end

  protected abstract def parse : Nil

  def validate : Nil
    definition = @definition
    given_arguments = @arguments

    # TODO: Check for missing required args.
  end
end
