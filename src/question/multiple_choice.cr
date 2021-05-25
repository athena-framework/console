require "./abstract_choice"

class Athena::Console::Question::MultipleChoice(T) < Athena::Console::Question::AbstractChoice(T, Array(T))
  protected def default_validator(answer : T?) : Array(T)
    self.selected_choices answer
  end

  protected def parse_answers(answer : T?) : Array(String)
    answer.try(&.split(',')) || [""]
  end
end
