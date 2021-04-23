require "./wrappable_output_formatter_interface"

class Athena::Console::Formatter::OutputFormatter
  include Athena::Console::Formatter::WrappableOutputFormatterInterface

  getter style_stack : ACON::Formatter::OutputFormatterStyleStack = ACON::Formatter::OutputFormatterStyleStack.new

  # :inherit:
  property? decorated : Bool

  @styles = Hash(String, ACON::Formatter::OutputFormatterStyleInterface).new
  @current_line_length = 0

  def initialize(@decorated : Bool = false, styles : ACON::Formatter::Mode? = nil)
    self.set_style "error", ACON::Formatter::OutputFormatterStyle.new(:white, :red)
    self.set_style "info", ACON::Formatter::OutputFormatterStyle.new(:green)
    self.set_style "comment", ACON::Formatter::OutputFormatterStyle.new(:yellow)
    self.set_style "question", ACON::Formatter::OutputFormatterStyle.new(:black, :cyan)
  end

  def set_style(name : String, style : ACON::Formatter::OutputFormatterStyleInterface) : Nil
    @styles[name.downcase] = style
  end

  def has_style?(name : String) : Bool
    @styles.has_key? name.downcase
  end

  def style(name : String) : ACON::Formatter::OutputFormatterStyleInterface
    @styles[name.downcase]
  end

  def format(message : String?) : String
    self.format_and_wrap message, 0
  end

  def format_and_wrap(message : String?, width : Int32?) : String
    offset = 0
    output = ""

    @current_line_length = 0

    message.scan(/<(([a-z][^<>]*+) | \/([a-z][^<>]*+)?)>/ix) do |match|
      pos = match.begin.not_nil!
      text = match[0]

      next if pos != 0 && '\\' == message[pos - 1]

      # Add text up to next tag.
      output += self.apply_current_style message[offset, pos - offset], output, width
      offset = pos + text.size

      tag = if open = '/' != text.char_at(1)
              match[2]
            else
              match[3]? || ""
            end

      pp pos, text, tag

      if !open && !tag
        pp "pop"
        @style_stack.pop
      elsif (style = self.create_style_from_string(tag)).nil?
        output += self.apply_current_style text, output, width
      elsif open
        pp "push"
        @style_stack << style
      else
        pp "pop style"
        @style_stack.pop style
      end
    end

    output += self.apply_current_style message[offset..], output, width

    output.gsub /\\</, "<"
  end

  private def apply_current_style(text : String, current : String, width : Int32)
    return "" if text.empty?

    if width.zero?
      pp self.decorated?, @style_stack.current
      return self.decorated? ? @style_stack.current.apply(text) : text
    end

    if @current_line_length.zero? && !current.empty?
      text = text.lstrip
    end

    if !@current_line_length.zero?
      i = width - @current_line_length
      prefix = "#{text[0, i]}\n"
      text = text[i..]
    else
      prefix = ""
    end

    # TODO: Something about replacing stuff.

    if !@current_line_length.zero? && !current.empty? && "\n" != current[-1]
      text = "\n#{text}"
    end

    lines = text.split "\n"

    pp lines

    lines.each do |line|
      @current_line_length += line.size

      @current_line_length = 0 if width < @current_line_length
    end

    if self.decorated?
      lines.each_with_index do |line, idx|
        lines[idx] = @style_stack.current.apply(line)
      end
    end

    lines.join "\n"
  end

  private def create_style_from_string(tag : String) : ACON::Formatter::OutputFormatterStyleInterface?
    if style = @styles[tag]?
      return style
    end

    # TODO: Handle creating generic styles.

    nil
  end
end
