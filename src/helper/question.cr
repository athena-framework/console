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

    return question.default unless input.interactive?

    if input.is_a?(ACON::Input::Streamable) && (stream = input.stream)
      @stream = stream
    end

    begin
      unless validator = question.validator
        return self.do_ask output, question
      end

      exit 1
    rescue ex : ACON::Exceptions::MissingInput
      input.interactive = false

      raise ex
    end
  end

  protected def write_prompt(output : ACON::Output::Interface, question : ACON::Question) : Nil
    message = question.question

    # TODO: Handle Choice questions

    output.print message
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

    if @@stty && ACON::Terminal.has_stty_available?
      stty_mode = `stty -g`
      system "stty -echo"
    elsif input_stream.tty?
    end

    response = input_stream.gets 4096

    if @@stty && ACON::Terminal.has_stty_available?
      system "stty #{stty_mode}"
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
end
