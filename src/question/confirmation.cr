class Athena::Console::Question::Confirmation < Athena::Console::Question(Bool)
  @true_answer_regex : Regex

  def initialize(question : String, default : Bool = true, @true_answer_regex : Regex = /^y/i)
    super question, default

    self.normalizer = ->default_normalizer(String | Bool)
  end

  private def default_normalizer(answer : String | Bool) : Bool
    if answer.is_a? Bool
      return answer
    end

    answer_is_true = answer.matches? @true_answer_regex

    if false == @default
      return !answer.blank? && answer_is_true
    end

    answer.empty? || answer_is_true
  end
end
