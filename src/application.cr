require "semantic_version"

class Athena::Console::Application
  @terminal : ACON::Terminal
  @version : SemanticVersion

  setter default_command : String = "list"
  property? auto_exit : Bool = true
  property? catch_exceptions : Bool = true
  getter? single_command : Bool = false

  @definition : ACON::Input::Definition? = nil
  @running_command : ACON::Command? = nil

  def self.new(name : String, version : String = "0.1.0") : self
    new name, SemanticVersion.parse version
  end

  def initialize(@name : String, @version : SemanticVersion = SemanticVersion.new(0, 1, 0))
    @terminal = ACON::Terminal.new

    # TODO: Emit events when certain signals are triggered.
    # This'll require the ability to optional set an event dispatcher on this type.
  end

  def run(input : ACON::Input::InputInterface = ACON::Input::ARGVInput.new, output : ACON::Output::OutputInterface = ACON::Output::ConsoleOutput.new) : ACON::Command::Status
    ENV["LINES"] = @terminal.height.to_s
    ENV["COLUMNS"] = @terminal.width.to_s

    self.configure_io input, output

    begin
      exit_status = self.do_run input, output
    rescue ex : Exception
      raise ex unless @catch_exceptions

      self.render_exception ex, output

      exit_status = ACON::Command::Status::FAILURE
    end

    if @auto_exit
      exit exit_status.value
    end

    exit_status
  end

  def do_run(input : ACON::Input::InputInterface, output : ACON::Output::OutputInterface) : ACON::Command::Status
    if input.has_parameter? "--version", "-V", only_params: true
      output.puts self.get_long_version

      return ACON::Command::Status::SUCCESS
    end

    input.bind self.definition

    ACON::Command::Status::SUCCESS
  end

  def render_exception(ex : Exception, output : ACON::Output::ConsoleOutputInterface) : Nil
    self.render_exception ex, output.error_output
  end

  def render_exception(ex : Exception, output : ACON::Output::OutputInterface) : Nil
    output.puts "", :quiet

    self.do_render_exception ex, output

    if running_command = @running_command
      output.puts "<info>COMMAND NAME</info>", :quiet
      output.puts "", :quiet
    end
  end

  def definition : ACON::Input::Definition
    @definition ||= self.default_input_definition

    if self.single_command?
      input_definition = @definition.not_nil!
      input_definition.arguments = Array(ACON::Input::Argument).new

      return input_definition
    end

    @definition.not_nil!
  end

  def definition=(@definition : ACON::Input::Definition)
  end

  def get_long_version : String
    "#{@name} <info>#{@version}</info>"
  end

  protected def configure_io(input : ACON::Input::InputInterface, output : ACON::Output::OutputInterface) : Nil
    if input.has_parameter? "--ansi", only_params: true
      output.decorated = true
    elsif input.has_parameter? "--no-ansi", only_params: true
      output.decorated = false
    end

    if input.has_parameter? "--no-interaction", "-n", only_params: true
      input.interactive = false
    end

    case shell_verbosity = ENV["SHELL_VERBOSITY"]?.try &.to_i
    when -1 then output.verbosity = :quiet
    when  1 then output.verbosity = :verbose
    when  2 then output.verbosity = :very_verbose
    when  3 then output.verbosity = :debug
    else
      shell_verbosity = 0
    end

    if input.has_parameter? "--quiet", "-q", only_params: true
      output.verbosity = :quiet
      shell_verbosity = -1
    else
      if input.has_parameter?("-vvv", "--verbose=3", only_params: true) || "3" == input.parameter("--verbose", false, true)
        output.verbosity = :debug
        shell_verbosity = 3
      elsif input.has_parameter?("-vv", "--verbose=2", only_params: true) || "2" == input.parameter("--verbose", false, true)
        output.verbosity = :very_verbose
        shell_verbosity = 2
      elsif input.has_parameter?("-v", "--verbose=1", only_params: true) || input.has_parameter?("--verbose") || input.parameter("--verbose", false, true)
        output.verbosity = :verbose
        shell_verbosity = 1
      end
    end

    if -1 == shell_verbosity
      input.interactive = false
    end

    ENV["SHELL_VERBOSITY"] = shell_verbosity.to_s
  end

  protected def default_input_definition : ACON::Input::Definition
    ACON::Input::Definition.new(
      ACON::Input::Argument.new("command", :required, "The command to execute"),
      ACON::Input::Option.new("help", "h", description: "Display help for the given command. When no command is given display help for the <info>#{@default_command}</info> command"),
      ACON::Input::Option.new("quiet", "q", description: "Do not output any message"),
      ACON::Input::Option.new("verbose", "v|vv|vvv", description: "Increase the verbosity of messages: 1 for normal output, 2 for more verbose output and 3 for debug"),
      ACON::Input::Option.new("version", "V", description: "Display this application version"),
      ACON::Input::Option.new("ansi", value_mode: :negatable, description: "Display this application version"),
      ACON::Input::Option.new("no-interaction", "n", description: "Do not ask any interactive question"),
    )
  end

  protected def do_render_exception(ex : Exception, output : ACON::Output::OutputInterface) : Nil
    loop do
      message = (ex.message || "").strip

      if message.empty? || ACON::Output::Verbosity::VERBOSE <= output.verbosity
        title = "  [#{ex.class}]  "
        len = title.size
      else
        len = 0
        title = ""
      end

      width = @terminal.width ? @terminal.width - 1 : Int32::MAX
      lines = [] of Tuple(String, Int32)

      message.split(/(\r?\n)/) do |line|
        self.split_string_by_width(line, width - 4) do |l|
          line_length = l.size + 4
          lines << {l, line_length}

          len = Math.max line_length, len
        end
      end

      messages = [] of String

      if !ex.is_a?(ACON::Exceptions::ConsoleException) || ACON::Output::Verbosity::VERBOSE <= output.verbosity
        if trace = ex.backtrace?.try &.first
          messages << "<comment>At #{ACON::Formatter::OutputFormatter.escape trace}</comment>" # TODO: Finish this line/file message.
        end
      end

      messages << (empty_line = "<error>#{" "*len}</error>")

      if messages.empty? || ACON::Output::Verbosity::VERBOSE <= output.verbosity
        messages << "<error>#{title}#{" "*(Math.max(0, len - title.size))}</error>"
      end

      lines.each do |line|
        messages << "<error>  #{ACON::Formatter::OutputFormatter.escape line[0]}  #{" "*(len - line[1])}</error>"
      end

      messages << empty_line
      messages << ""

      messages.each do |m|
        output.puts m, :quiet
      end

      if ACON::Output::Verbosity::VERBOSE <= output.verbosity
      end

      break unless (ex = ex.cause)
    end
  end

  private def split_string_by_width(line : String, width : Int32, & : String -> Nil) : Nil
    line.split(/(.{#{width}}?)/, remove_empty: true) do |match|
      yield match.as(String)
    end
  end
end
