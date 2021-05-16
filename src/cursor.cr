struct Athena::Console::Cursor
  @output : ACON::Output::Interface
  @input : IO

  def initialize(@output : ACON::Output::Interface, input : IO? = nil)
    @input = input || STDIN
  end

  def move_up(lines : Int32 = 1) : self
    @output.print "\x1b[#{lines}A"

    self
  end

  def move_down(lines : Int32 = 1) : self
    @output.print "\x1b[#{lines}B"

    self
  end

  def move_right(lines : Int32 = 1) : self
    @output.print "\x1b[#{lines}C"

    self
  end

  def move_left(lines : Int32 = 1) : self
    @output.print "\x1b[#{lines}D"

    self
  end

  def move_to_column(column : Int32) : self
    @output.print "\x1b[#{column}G"

    self
  end

  def move_to_position(column : Int32, row : Int32) : self
    @output.print "\x1b[#{row + 1};#{column}H"

    self
  end

  def save_position : self
    @output.print "\x1b7"

    self
  end

  def restore_position : self
    @output.print "\x1b8"

    self
  end

  def hide : self
    @output.print "\x1b[?25l"

    self
  end

  def show : self
    @output.print "\x1b[?25h\x1b[?0c"

    self
  end

  def clear_line : self
    @output.print "\x1b[2K"

    self
  end

  def clear_line_after : self
    @output.print "\x1b[K"

    self
  end

  def clear_output : self
    @output.print "\x1b[0J"

    self
  end

  def clear_screen : self
    @output.print "\x1b[2J"

    self
  end

  def current_position : {Int32, Int32}
    return {1, 1} unless @input.tty?

    stty_mode = `stty -g`
    system "stty -icanon -echo"

    @input.print "\033[6n"

    bytes = @input.peek

    system "stty #{stty_mode}"

    String.new(bytes.not_nil!).match /\e\[(\d+);(\d+)R/

    {$2.to_i, $1.to_i}
  end
end
