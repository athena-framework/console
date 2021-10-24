require "./question_base"

# This namespaces contains various questions that can be asked via the `ACON::Helper::Question` helper.
#
# This class can also be used to ask the user for more information.
class Athena::Console::Question(T)
  include Athena::Console::Question::QuestionBase(T)

  property validator : Proc(T, T)? = nil

  def set_validator(&@validator : T -> T) : Nil
  end
end
