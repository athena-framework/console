require "./question_base"

class Athena::Console::Question(T)
  include Athena::Console::Question::QuestionBase(T)

  property validator : Proc(T, T)? = nil
end
