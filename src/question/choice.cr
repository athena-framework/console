require "./abstract_choice"

class Athena::Console::Question::Choice(T) < Athena::Console::Question::AbstractChoice(T, T?)
  protected def default_validator(answer : T?) : T?
    self.selected_choices(answer).first?
  end

  protected def parse_answers(answer : T?) : Array(String)
    [answer || ""]
  end
end
