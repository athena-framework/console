class Athena::Console::Question(T); end

require "./question_base"

abstract class Athena::Console::Question::AbstractChoice(T, ChoiceType)
  include Athena::Console::Question::QuestionBase(T?)

  getter choices : Hash(String | Int32, T)
  getter error_message : String = "Value '%s' is invalid"

  property prompt : String = " > "
  property validator : Proc(T?, ChoiceType)? = nil

  def self.new(question : String, choices : Indexable(T), default : Int | T | Nil = nil)
    choices_hash = Hash(String | Int32, T).new

    choices.each_with_index do |choice, idx|
      choices_hash[idx] = choice
    end

    new question, choices_hash, (default.is_a?(Int) ? choices[default]? : default)
  end

  def initialize(question : String, choices : Hash(String | Int32, T), default : T? = nil)
    super question, default

    raise ACON::Exceptions::Logic.new "Choice question must have at least 1 choice available." if choices.empty?

    @choices = choices.transform_keys &.as String | Int32

    self.validator = ->default_validator(T?)
    self.autocompleter_values = choices
  end

  private def selected_choices(answer : String?) : Array(T)
    selected_choices = self.parse_answers answer

    if @trimmable
      selected_choices.map! &.strip
    end

    valid_choices = [] of String
    selected_choices.each do |value|
      results = [] of String

      @choices.each do |key, choice|
        results << key.to_s if choice == value
      end

      raise ACON::Exceptions::InvalidArgument.new %(The provided answer is ambiguous.  Value should be one of #{results.join(" or ")}) if results.size > 1

      result = @choices.find { |(k, v)| v == value || k.to_s == value }.try &.first.to_s

      # If none of the keys are a string, assume the original choice values were an Indexable.
      if @choices.keys.none?(&.is_a?(String)) && result
        result = @choices[result.to_i]
      elsif @choices.has_key? value
        result = @choices[value]
      elsif @choices.has_key? result
        result = @choices[result]
      end

      if result.nil?
        raise ACON::Exceptions::InvalidArgument.new sprintf(@error_message, value)
      end

      valid_choices << result
    end

    valid_choices
  end

  protected abstract def default_validator(answer : T?) : ChoiceType
  protected abstract def parse_answers(answer : T?) : Array(String)
end
