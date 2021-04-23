abstract class Athena::Console::Output; end

class Athena::Console::IOOutput < Athena::Console::Output
  @io : IO

  def initialize(
    @io : IO,
    verbosity : ACON::Output::Verbosity? = :normal,
    decorated : Bool? = nil,
    formatter : ACON::Formatter::OutputFormatterInterface? = nil
  )
    decorated = self.has_color_support? if decorated.nil?

    super verbosity, decorated, formatter
  end

  protected def do_write(message : String, new_line : Bool) : Nil
    new_line ? @io.puts(message) : @io.print(message)
  end

  private def has_color_support? : Bool
    # Respect https://no-color.org.
    return false if "false" == ENV["NO_COLOR"]?
    return true if "Hyper" == ENV["TERM_PROGRAM"]?

    @io.tty?
  end
end
