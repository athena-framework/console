class Athena::Console::Helper::Question < Athena::Console::Helper
  @@stty : Bool = true

  def self.disable_stty : Nil
    @@stty = false
  end

  @stream : IO? = nil

  def ask(input : ACON::Input::Interface, output : ACON::Output::Interface, question : ACON::Question)
    if output.is_a? ACON::Output::ConsoleOutputInterface
      output = output.error_output
    end

    return self.default_answer question unless input.interactive?

    if input.is_a?(ACON::Input::Streamable) && (stream = input.stream)
      @stream = stream
    end

    begin
      unless validator = question.validator
        return self.do_ask output, question
      end

      self.validate_attempts(output, question) do
        self.do_ask output, question
      end
    rescue ex : ACON::Exceptions::MissingInput
      input.interactive = false

      raise ex
    end
  end

  protected def format_choice_question_choices(question : ACON::Question::Choice, tag : String) : Array(String)
    messages = Array(String).new

    choices = question.choices

    max_width = choices.keys.max_of &.size

    choices.each do |k, v|
      padding = " " * (max_width - k.size)

      messages << "  [<#{tag}>#{k}#{padding}</#{tag}>] #{v}"
    end

    messages
  end

  protected def write_error(output : ACON::Output::Interface, error : Exception) : Nil
    message = if (helper_set = self.helper_set) && (formatter_helper = helper_set[ACON::Helper::Formatter]?)
                formatter_helper.format_block error.message || "", "error"
              else
                "<error>#{error.message}</error>"
              end

    output.puts message
  end

  protected def write_prompt(output : ACON::Output::Interface, question : ACON::Question) : Nil
    message = question.question

    # TODO: Handle Choice questions

    output.print message
  end

  private def default_answer(question : ACON::Question)
    default = question.default

    return default if default.nil?

    if validator = question.validator
      validator.call default
    elsif question.is_a? ACON::Question::Choice
      choices = question.choices

      # unless question.multi_select?
      #   return choices[default]? || default
      # end

      # TODO: Handle multiselect
    end

    default
  end

  private def do_ask(output : ACON::Output::Interface, question : ACON::Question)
    self.write_prompt output, question

    input_stream = @stream || STDIN
    autocomplete = question.autocompleter

    # TODO: Handle invalid input IO

    if autocomplete.nil? || !@@stty || !ACON::Terminal.has_stty_available?
      response = nil

      if question.hidden?
        begin
          hidden_response = self.hidden_response output, input_stream
          response = question.trimmable? ? hidden_response.strip : hidden_response
        rescue ex : ACON::Exceptions::ConsoleException
          raise ex unless question.hidden_fallback?
        end
      end

      if response.nil?
        raise ACON::Exceptions::MissingInput.new "Aborted." unless (response = self.read_input input_stream, question)
        response = response.strip if question.trimmable?
      end
    else
      response = ""
    end

    # TODO: Handle output sections

    question.process_response response
  end

  private def hidden_response(output : ACON::Output::Interface, input_stream : IO) : String
    # TODO: Support Windows
    {% raise "Athena::Console component does not support Windows yet." if flag?(:win32) %}

    response = if input_stream.tty? && input_stream.responds_to? :noecho
                 input_stream.noecho &.gets 4096
               elsif @@stty && ACON::Terminal.has_stty_available?
                 stty_mode = `stty -g`
                 system "stty -echo"

                 input_stream.gets(4096).tap { system "stty #{stty_mode}" }
               elsif input_stream.tty?
                 raise ACON::Exceptions::MissingInput.new "Aborted."
               end

    raise ACON::Exceptions::MissingInput.new "Aborted." if response.nil?

    output.puts ""

    response
  end

  private def read_input(input_stream : IO, question : ACON::Question) : String?
    unless question.multi_line?
      return input_stream.gets 4096
    end

    # TODO: Handle multi line input

    nil
  end

  private def validate_attempts(output : ACON::Output::Interface, question : ACON::Question)
    error = nil
    attempts = question.max_attempts

    while attempts.nil? || attempts > 0
      begin
        self.write_error output, error if error

        return question.validator.not_nil!.call yield
      rescue ex : ACON::Exceptions::ValidationFailed
        pp ex
        raise ex
      rescue ex : Exception
        error = ex
      end
    end

    raise error.not_nil!
  end
end
