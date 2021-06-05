require "./output"

class Athena::Console::Style::Athena < Athena::Console::Style::Output
  private MAX_LINE_LENGTH = 120

  getter question_helper : ACON::Helper::Question { ACON::Helper::AthenaQuestionHelper.new }

  @input : ACON::Input::Interface
  @buffered_output : ACON::Output::SizedBuffer

  @line_length : Int32

  def initialize(@input : ACON::Input::Interface, output : ACON::Output::Interface)
    width = ACON::Terminal.new.width || MAX_LINE_LENGTH

    @buffered_output = ACON::Output::SizedBuffer.new {{flag?(:windows) ? 4 : 2}}, output.verbosity, false, output.formatter.dup
    @line_length = Math.min(width - {{flag?(:windows) ? 1 : 0}}, MAX_LINE_LENGTH)

    super output
  end

  def ask(question : String, default : _)
    self.ask ACON::Question.new question, default
  end

  def ask(question : ACON::Question::QuestionBase)
    if @input.interactive?
      self.auto_prepend_block
    end

    answer = self.question_helper.ask @input, self, question

    if @input.interactive?
      self.new_line
      @buffered_output.print "\n"
    end

    answer
  end

  def ask_hidden(question : String)
    question = ACON::Question(String?).new question, nil

    question.hidden = true

    self.ask question
  end

  def block(messages : String | Enumerable(String), type : String? = nil, style : String? = nil, prefix : String = " ", padding : Bool = false, escape : Bool = true) : Nil
    messages = messages.is_a?(Enumerable(String)) ? messages : {messages}

    self.auto_prepend_block
    self.puts self.create_block(messages, type, style, prefix, padding, escape)
    self.new_line
  end

  def caution(messages : String | Enumerable(String)) : Nil
    self.block messages, "CAUTION", "fg=white;bg=red", " ! ", true
  end

  def choice(question : String, choices : Indexable | Hash, default = nil)
    self.ask ACON::Question::Choice.new question, choices, default
  end

  def comment(messages : String | Enumerable(String)) : Nil
    self.block messages, prefix: "<fg=default;bg=default> // </>", escape: false
  end

  def confirm(question : String, default : Bool = true) : Bool
    self.ask ACON::Question::Confirmation.new question, default
  end

  def error(messages : String | Enumerable(String)) : Nil
    self.block messages, "ERROR", "fg=white;bg=red", padding: true
  end

  def error_style : self
    self.class.new @input, self.error_output
  end

  def info(messages : String | Enumerable(String)) : Nil
    self.block messages, "INFO", "fg=green", padding: true
  end

  def listing(*elements : String) : Nil
    self.listing elements
  end

  def listing(elements : Enumerable) : Nil
    self.auto_prepend_text
    elements.each do |element|
      self.puts " * #{element}"
    end
    self.new_line
  end

  def new_line(count : Int32 = 1) : Nil
    super
    @buffered_output.print "\n" * count
  end

  def note(messages : String | Enumerable(String)) : Nil
    self.block messages, "NOTE", "fg=yellow", " ! "
  end

  def puts(messages : String | Enumerable(String), verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
    messages = messages.is_a?(String) ? {messages} : messages

    messages.each do |message|
      super message, verbosity, output_type
      self.write_buffer message, true, verbosity, output_type
    end
  end

  def print(messages : String | Enumerable(String), verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
    messages = messages.is_a?(String) ? {messages} : messages

    messages.each do |message|
      super message, verbosity, output_type
      self.write_buffer message, false, verbosity, output_type
    end
  end

  def section(message : String) : Nil
    self.auto_prepend_block
    self.puts "<comment>#{ACON::Formatter::Output.escape_trailing_backslash message}</>"
    self.puts %(<comment>#{"-" * ACON::Helper.remove_decoration(self.formatter, message).size}</>)
    self.new_line
  end

  def success(messages : String | Enumerable(String)) : Nil
    self.block messages, "OK", "fg=black;bg=green", padding: true
  end

  # def table(headers : Enumerable, rows : Enumerable(Enumerable)) : Nil
  # end

  def text(messages : String | Enumerable(String)) : Nil
    self.auto_prepend_text

    messages = messages.is_a?(Enumerable(String)) ? messages : {messages}

    messages.each do |message|
      self.puts " #{message}"
    end
  end

  def title(message : String) : Nil
    self.auto_prepend_block
    self.puts "<comment>#{ACON::Formatter::Output.escape_trailing_backslash message}</>"
    self.puts %(<comment>#{"=" * ACON::Helper.remove_decoration(self.formatter, message).size}</>)
    self.new_line
  end

  def warning(messages : String | Enumerable(String)) : Nil
    self.block messages, "WARNING", "fg=black;bg=yellow", padding: true
  end

  # def progress_start(max : Int32 = 0) : Nil
  # end

  # def progress_advance(step : Int32 = 1) : Nil
  # end

  # def progress_finish : Nil
  # end

  private def auto_prepend_block : Nil
    chars = @buffered_output.fetch

    if chars.empty?
      return self.new_line
    end

    self.new_line 2 - chars.count '\n'
  end

  private def auto_prepend_text : Nil
    fetched = @buffered_output.fetch
    self.new_line unless fetched.ends_with? "\n"
  end

  private def create_block(messages : Enumerable(String), type : String? = nil, style : String? = nil, prefix : String = " ", padding : Bool = false, escape : Bool = true) : Array(String)
    indent_length = 0
    prefix_length = ACON::Helper.remove_decoration(self.formatter, prefix).size
    lines = [] of String

    unless type.nil?
      type = "[#{type}] "
      indent_length = type.size
      line_indentation = " " * indent_length
    end

    messages.each_with_index do |message, idx|
      message = ACON::Formatter::Output.escape message if escape

      decoration_length = message.size - ACON::Helper.remove_decoration(self.formatter, message).size
      message_line_length = Math.min(@line_length - prefix_length - indent_length + decoration_length, @line_length)
      lines.concat message.gsub(/([^\n]{#{message_line_length}})\ */, "\\0\n").split "\n"

      lines << "" if messages.size > 1 && idx < (messages.size - 1)
    end

    first_line_index = 0
    if padding && self.decorated?
      first_line_index = 1
      lines.unshift ""
      lines << ""
    end

    lines.map_with_index do |line, idx|
      unless type.nil?
        line = first_line_index == idx ? "#{type}#{line}" : "#{line_indentation}#{line}"
      end

      line = "#{prefix}#{line}"
      line += " " * Math.max @line_length - ACON::Helper.remove_decoration(self.formatter, line).size, 0

      if style
        line = "<#{style}>#{line}</>"
      end

      line
    end
  end

  private def write_buffer(message : String | Enumerable(String), new_line : Bool, verbosity : ACON::Output::Verbosity = :normal, output_type : ACON::Output::Type = :normal) : Nil
    @buffered_output.write message, new_line, verbosity, output_type
  end
end
