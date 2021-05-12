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

  def ask_question(question : ACON::Question)
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

  def block(messages : String | Enumerable(String), type : String? = nil, style : String? = nil, prefix : String = " ", padding : Bool = false, escape : Bool = true) : Nil
    messages = messages.is_a?(Enumerable(String)) ? messages : {messages}

    self.auto_prepend_block
    self.create_block(messages, type, style, prefix, padding, escape).each do |line|
      self.puts line
    end
    self.new_line
  end

  def confirm(question : String, default : Bool = true) : Bool
    self.ask_question ACON::Question::Confirmation.new question, default
  end

  def new_line(count : Int32 = 1) : Nil
    super
    @buffered_output.print "\n" * count
  end

  private def auto_prepend_block : Nil
    chars = @buffered_output.fetch

    if chars.empty?
      return self.new_line
    end

    self.new_line 2 - chars.count '\n'
  end

  private def create_block(messages : Enumerable(String), type : String? = nil, style : String? = nil, prefix : String = " ", padding : Bool = false, escape : Bool = true) : Array(String)
    indent_length = 0
    prefix_length = ACON::Helper.remove_decoration(self.formatter, prefix).size
    lines = [] of String

    unless type.nil?
      type = "[#{type}]"
      indent_length = type.size
      line_indentation = " " * indent_length
    end

    messages.each_with_index do |message, idx|
      message = ACON::Formatter::OutputFormatter.escape message if escape

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
        line = "<#{style}>#{line}</#{style}>"
      end

      line
    end
  end
end
