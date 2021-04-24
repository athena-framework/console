require "./input_interface"

abstract class Athena::Console::Input
  include Athena::Console::Input::InputInterface

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

  def bind(definition : ACON::Input::Definition) : Nil
    @arguments.clear
    @options.clear
    @definition = definition

    pp "bind"

    self.parse
  end

  protected abstract def parse : Nil

  def validate : Nil
    definition = @definition
    given_arguments = @arguments

    # TODO: Check for missing required args.
  end
end
