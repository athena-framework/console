require "./io"

class Athena::Console::Output::Section < Athena::Console::Output::IO
  protected getter lines = 0

  @content = [] of String
  @sections : Array(self)
  @terminal : ACON::Terminal

  def initialize(
    io : ::IO,
    @sections : Array(self),
    verbosity : ACON::Output::Verbosity,
    decorated : Bool,
    formatter : ACON::Formatter::Interface
  )
    super io, verbosity, decorated, formatter

    @terminal = ACON::Terminal.new
    @sections.unshift self
  end

  def content : String
    @content.join
  end

  def clear(lines : Int32? = nil) : Nil
    return if @content.empty? || !self.decorated?

    if lines
      # Double the lines to account for each new line added between content
      @content.delete_at (-lines * 2)..-1
    else
      lines = @lines
      @content.clear
    end

    @lines -= lines

    @io.print self.pop_stream_content_until_current_section(lines)
  end

  def overwrite(message : String) : Nil
    self.clear
    self.puts message
  end

  protected def add_content(input : String) : Nil
    input.each_line do |line|
      lines = (self.get_display_width(line) // @terminal.width).ceil
      @lines += lines.zero? ? 1 : lines
      @content.push line, "\n"
    end
  end

  protected def do_write(message : String, new_line : Bool) : Nil
    return super unless self.decorated?

    erased_content = self.pop_stream_content_until_current_section

    self.add_content message
    super message, true
    super erased_content, false
  end

  private def get_display_width(input : String) : Int32
    ACON::Helper.width ACON::Helper.remove_decoration(self.formatter, input.gsub("\t", "        "))
  end

  private def pop_stream_content_until_current_section(lines_to_clear_from_current_section : Int32 = 0) : String
    number_of_lines_to_clear = lines_to_clear_from_current_section
    erased_content = Array(String).new

    @sections.each do |section|
      break if self == section

      number_of_lines_to_clear += section.lines
      erased_content << section.content
    end

    if number_of_lines_to_clear > 0
      # Move cursor up n lines
      @io.print "\e[#{number_of_lines_to_clear}A"

      # Erase to end of screen
      @io.print "\e[0J"
    end

    erased_content.reverse.join
  end
end
