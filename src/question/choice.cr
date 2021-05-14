class Athena::Console::Question(T); end

class Athena::Console::Question::Choice(T) < Athena::Console::Question(T?)
  getter choices : Array(T)
  getter? multi_select : Bool = false
  getter error_message : String = "Value '%s' is invalid"

  property prompt : String = " > "

  def initialize(question : String, choices : Enumerable(T), default : T? = nil)
    super question, default

    raise ACON::Exceptions::Logic.new "Choice question must have at least 1 choice available." if choices.empty?

    @choices = choices.to_a

    self.validator = ->default_validator(T?)
  end

  private def default_validator(answer : T?) : T?
    answer
  end
end
