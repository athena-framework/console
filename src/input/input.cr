require "./input_interface"

abstract class Athena::Console::Input
  include Athena::Console::Input::InputInterface

  property? interactive : Bool = true

  @arguments = Array(ACON::Input::Argument).new
  @definition : ACON::Input::Definition
  @options = Array(ACON::Input::Option).new

  def initialize(definition : ACON::Input::Definition? = nil)
    if definition.nil?
      @definition = ACON::Input::Definition.new
    else
      @definition = definition
      self.bind definition.not_nil!
      self.validate
    end
  end

  def bind(definition : ACON::Input::Definition) : Nil
    @arguments = Array(ACON::Input::Argument).new
    @options = Array(ACON::Input::Option).new
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
