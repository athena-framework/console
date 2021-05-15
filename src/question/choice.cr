class Athena::Console::Question(T); end

class Athena::Console::Question::Choice(T) < Athena::Console::Question(T?)
  getter choices : Hash(String, T)
  getter? multi_select : Bool = false
  getter error_message : String = "Value '%s' is invalid"

  property prompt : String = " > "

  def self.new(question : String, choices : Indexable(T), default : Int | T | Nil = nil)
    choices_hash = Hash(String, T).new

    choices.each_with_index do |choice, idx|
      choices_hash[idx.to_s] = choice
    end

    new question, choices_hash, (default.is_a?(Int) ? choices[default]? : default)
  end

  def initialize(question : String, choices : Hash(String, T), default : T? = nil)
    super question, default

    raise ACON::Exceptions::Logic.new "Choice question must have at least 1 choice available." if choices.empty?

    @choices = choices

    self.validator = ->default_validator(T?)
  end

  private def default_validator(answer : T?) : T?
    selected_choices = if @multi_select
                         # TODO: Validate non comma separated values
                         answer ? answer.split ',' : [""]
                       else
                         [answer || ""]
                       end

    if @trimmable
      selected_choices.map! &.strip
    end

    multi_select_choices = [] of String
    selected_choices.each do |value|
      results = [] of String

      @choices.each do |key, choice|
        results << key if choice == value
      end

      raise ACON::Exceptions::InvalidArgument.new "Amb" if results.size > 1

      result = @choices.values.find { |v| v == value }

      if result.nil? && @choices.has_key? value
        result = value
      end

      if result.nil?
        raise ACON::Exceptions::InvalidArgument.new sprintf(@error_message, value)
      end

      multi_select_choices << result
    end

    # return multi_select_choices if @multi_select

    multi_select_choices.first?
  end
end
