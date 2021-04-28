require "./interface"

abstract class Athena::Console::Input
  include Athena::Console::Input::Interface

  property? interactive : Bool = true

  @arguments = Hash(String, String | Array(String)).new
  @definition : ACON::Input::Definition
  @options = Hash(String, String | Array(String | Bool | Nil) | Bool | Nil).new

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

  def option(name : String)
    raise "The #{name} option does not exist." unless @definition.has_option? name

    @options[name]? || @definition.option(name).default
  end

  def option(name : String, type : T.class) : T forall T
    self.option(name).as T
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
