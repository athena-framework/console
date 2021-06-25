require "semantic_version"
require "levenshtein"

class Athena::Console::Application
  @terminal : ACON::Terminal

  getter version : SemanticVersion
  getter name : String

  @default_command : String = "list"

  # By default the application will auto [exit](https://crystal-lang.org/api/toplevel.html#exit(status=0):NoReturn-class-method) after executing a command.
  # This method can be used to disable that functionality.
  # If set to `false`, the `ACON::Command::Status` of the executed command is returned from `#run`.
  # Otherwise the `#run` method never returns.
  #
  # ```
  # application = ACON::Application.new "My CLI"
  # appplication.auto_exit = false
  # exit_status = application.run
  # exit_status # => ACON::Command::Status::SUCCESS
  #
  # appplication.auto_exit = true
  # exit_status = application.run
  #
  # # This line is never reached.
  # exit_status
  # ```
  setter auto_exit : Bool = true
  property? catch_exceptions : Bool = true

  # Returns `true` if `self` only supports a single command.
  #
  # The main use case for this feature
  getter? single_command : Bool = false
  property helper_set : ACON::Helper::HelperSet { self.default_helper_set }
  setter command_loader : ACON::Loader::Interface? = nil

  @definition : ACON::Input::Definition? = nil
  @commands = Hash(String, ACON::Command).new
  @initialized : Bool = false
  @running_command : ACON::Command? = nil
  @wants_help : Bool = false

  def self.new(name : String, version : String = "0.1.0") : self
    new name, SemanticVersion.parse version
  end

  def initialize(@name : String, @version : SemanticVersion = SemanticVersion.new(0, 1, 0))
    @terminal = ACON::Terminal.new

    # TODO: Emit events when certain signals are triggered.
    # This'll require the ability to optional set an event dispatcher on this type.
  end

  # Adds the provided *command* instance to `self` allowing it be ran.
  def add(command : ACON::Command) : ACON::Command?
    self.init

    command.application = self

    unless command.enabled?
      command.application = nil

      return nil
    end

    # TODO: Do something about LazyCommands?

    @commands[command.name] = command

    command.aliases.each do |a|
      @commands[a] = command
    end

    command
  end

  # Returns if application should exit automatically after executing a command.
  # See `#auto_exit=`.
  def auto_exit? : Bool
    @auto_exit
  end

  # Yields each command within `self`, optionally only yields those within the provided *namespace*.
  def each_command(namespace : String? = nil, & : ACON::Command -> Nil) : Nil
    self.commands(namespace).each_value { |c| yield c }
  end

  # Returns all commands within `self`, optionally only including the ones within the provided *namespace*.
  def commands(namespace : String? = nil) : Hash(String, ACON::Command)
    self.init

    if namespace.nil?
      unless command_loader = @command_loader
        return @commands
      end

      commands = @commands.dup
      command_loader.names.each do |name|
        if !commands.has_key?(name) && self.has?(name)
          commands[name] = self.get name
        end
      end

      return commands
    end

    commands = Hash(String, ACON::Command).new
    @commands.each do |name, command|
      if namespace == self.extract_namespace(name, namespace.count(':') + 1)
        commands[name] = command
      end
    end

    if command_loader = @command_loader
      command_loader.names.each do |name|
        if !commands.has_key?(name) && namespace == self.extract_namespace(name, namespace.count(':') + 1) && self.has?(name)
          commands[name] = self.get name
        end
      end
    end

    commands
  end

  # Sets which command should be executed when no command name is provided in a multi command application.
  # By default this is `ACON::Commands::List`.
  #
  # For example, executing the following console script via `crystal run ./console.cr`
  # would result in `Hello world!` being printed instead of the default list output.
  #
  # ```
  # application = ACON::Application.new "My CLI"
  #
  # application.register "foo" do |_, output|
  #   output.puts "Hello world!"
  #   ACON::Command::Status::SUCCESS
  # end
  #
  # application.default_command "foo"
  #
  # application.run
  # ```
  #
  # ### Single Command Applications
  #
  # In some cases a CLI may only have one supported command in which passing the command's name each time is tedious.
  # In such a case an application may be declared as a single command application via the optional second argument *single_command*.
  # Passing `true` makes it so that any supplied arguments or options are passed to the default command.
  #
  # For example, executing the following console script via `crystal run ./console.cr George`
  # would result in `Hello George!` being printed.  If we tried this again without setting *single_command*
  # to `true`, it would error saying `Command 'George' is not defined.`
  #
  # ```
  # application = ACON::Application.new "My CLI"
  #
  # application.register "foo" do |input, output, command|
  #   output.puts %(Hello #{input.argument "name"}!)
  #   ACON::Command::Status::SUCCESS
  # end.argument("name", :required)
  #
  # application.default_command "foo", true
  #
  # application.run
  # ```
  #
  # WARNING: Arguments and options passed to the default command are ignored when `#single_command?` is `false`.
  def default_command(name : String, single_command : Bool = false) : self
    @default_command = name

    if single_command
      self.find name

      @single_command = true
    end

    self
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def find(name : String) : ACON::Command
    self.init

    aliases = Hash(String, String).new

    @commands.each_value do |command|
      command.aliases.each do |a|
        @commands[a] = command unless self.has? a
      end
    end

    return self.get name if self.has? name

    all_command_names = if command_loader = @command_loader
                          command_loader.names + @commands.keys
                        else
                          @commands.keys
                        end

    expression = "#{name.split(':').join("[^:]*:", &->Regex.escape(String))}[^:]*"
    commands = all_command_names.select(/^#{expression}/)

    if commands.empty?
      commands = all_command_names.select(/^#{expression}/i)
    end

    if commands.empty? || commands.select(/^#{expression}$/i).size < 1
      if pos = name.index ':'
        # Check if a namespace exists and contains commands
        self.find_namespace name[0...pos]
      end

      message = "Command '#{name}' is not defined."

      if (alternatives = self.find_alternatives name, all_command_names) && (!alternatives.empty?)
        alternatives.select! do |n|
          !self.get(n).hidden?
        end

        case alternatives.size
        when 1 then message += "\n\nDid you mean this?\n    "
        else        message += "\n\nDid you mean one of these?\n    "
        end

        message += alternatives.join("\n    ")
      end

      raise ACON::Exceptions::CommandNotFound.new message, alternatives
    end

    # Filter out aliases for commands which are already on the list.
    if commands.size > 1
      command_list = @commands.dup

      commands.select! do |name_or_alias|
        command = if !command_list.has_key?(name_or_alias)
                    command_list[name_or_alias] = @command_loader.not_nil!.get name_or_alias
                  else
                    command_list[name_or_alias]
                  end

        command_name = command.name

        aliases[name_or_alias] = command_name

        command_name == name_or_alias || !commands.includes? command_name
      end.uniq!

      usable_width = @terminal.width - 10
      max_len = commands.max_of &.size
      abbreviations = commands.map do |n|
        if command_list[n].hidden?
          commands.delete n

          next nil
        end

        abbreviation = "#{n.rjust max_len, ' '} #{command_list[n].description}"

        abbreviation.size > usable_width ? "#{abbreviation[0, usable_width - 3]}..." : abbreviation
      end

      if commands.size > 1
        suggestions = self.abbreviation_suggestions abbreviations.compact

        raise ACON::Exceptions::CommandNotFound.new "Command '#{name}' is ambiguous.\nDid you mean one of these?\n#{suggestions}", commands
      end
    end

    command = self.get commands.first

    raise ACON::Exceptions::CommandNotFound.new "The command '#{name}' does not exist." if command.hidden?

    command
  end

  def find_namespace(namespace : String) : String
    all_namespace_names = self.namespaces

    expression = "#{namespace.split(':').join("[^:]*:", &->Regex.escape(String))}[^:]*"
    namespaces = all_namespace_names.select(/^#{expression}/)

    if namespaces.empty?
      message = "There are no commands defined in the '#{namespace}' namespace."

      if (alternatives = self.find_alternatives namespace, all_namespace_names) && (!alternatives.empty?)
        case alternatives.size
        when 1 then message += "\n\nDid you mean this?\n    "
        else        message += "\n\nDid you mean one of these?\n    "
        end

        message += alternatives.join("\n    ")
      end

      raise ACON::Exceptions::NamespaceNotFound.new message, alternatives
    end

    exact = namespaces.includes? namespace

    if namespaces.size > 1 && !exact
      raise ACON::Exceptions::NamespaceNotFound.new "The namespace '#{namespace}' is ambiguous.\nDid you mean one of these?\n#{self.abbreviation_suggestions namespaces}", namespaces
    end

    exact ? namespace : namespaces.first
  end

  def extract_namespace(name : String, limit : Int32? = nil) : String
    # Pop off the shortcut name of the command.
    parts = name.split(':').tap &.pop

    (limit.nil? ? parts : parts[0...limit]).join ':'
  end

  def get(name : String) : ACON::Command
    self.init

    raise ACON::Exceptions::CommandNotFound.new "The command '#{name}' does not exist." unless self.has? name

    if !@commands.has_key? name
      raise ACON::Exceptions::CommandNotFound.new "The '#{name}' command cannot be found because it is registered under multiple names.  Make sure you don't set a different name via constructor or 'name='."
    end

    command = @commands[name]

    if @wants_help
      @wants_help = false

      help_command = self.get "help"
      help_command.as(ACON::Commands::Help).command = command

      return help_command
    end

    command
  end

  def has?(name : String) : Bool
    self.init

    return true if @commands.has_key? name

    if (command_loader = @command_loader) && command_loader.has? name
      self.add command_loader.get name

      true
    else
      false
    end
  end

  def namespaces : Array(String)
    namespaces = [] of String

    self.commands.each_value do |command|
      next if command.hidden?

      namespaces.concat self.extract_all_namespaces command.name.not_nil!

      command.aliases.each do |a|
        namespaces.concat self.extract_all_namespaces a
      end
    end

    namespaces.reject!(&.blank?).uniq!
  end

  def run(input : ACON::Input::Interface = ACON::Input::ARGV.new, output : ACON::Output::Interface = ACON::Output::ConsoleOutput.new) : ACON::Command::Status | NoReturn
    ENV["LINES"] = @terminal.height.to_s
    ENV["COLUMNS"] = @terminal.width.to_s

    self.configure_io input, output

    begin
      exit_status = self.do_run input, output
    rescue ex : Exception
      raise ex unless @catch_exceptions

      self.render_exception ex, output

      exit_status = if ex.is_a? ACON::Exceptions::ConsoleException
                      ACON::Command::Status.new ex.code.zero? ? 1 : ex.code
                    else
                      ACON::Command::Status::FAILURE
                    end
    end

    if @auto_exit
      exit exit_status.value
    end

    exit_status
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def do_run(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
    if input.has_parameter? "--version", "-V", only_params: true
      output.puts self.long_version

      return ACON::Command::Status::SUCCESS
    end

    input.bind self.definition rescue nil

    command_name = self.command_name input

    if input.has_parameter? "--help", "-h", only_params: true
      if command_name.nil?
        command_name = "help"
        input = ACON::Input::Hash.new(command_name: @default_command)
      else
        @wants_help = true
      end
    end

    if command_name.nil?
      command_name = @default_command
      definition = self.definition
      definition.arguments.merge!({
        "command" => ACON::Input::Argument.new("command", :optional, definition.argument("command").description, command_name),
      })
    end

    begin
      @running_command = nil

      command = self.find command_name
    rescue ex : Exception
      if !(ex.is_a?(ACON::Exceptions::CommandNotFound) && !ex.is_a?(ACON::Exceptions::NamespaceNotFound)) ||
         1 != (alternatives = ex.alternatives).size ||
         !input.interactive?
        # TODO: Handle dispatching

        raise ex
      end

      alternative = alternatives.not_nil!.first

      style = ACON::Style::Athena.new input, output

      style.block "\nCommand '#{command_name}' is not defined.\n", style: "error"

      unless style.confirm "Do you want to run '#{alternative}' instead?", false
        # TODO: Handle dispatching

        return ACON::Command::Status::FAILURE
      end

      command = self.find alternative
    end

    @running_command = command
    exit_status = self.do_run_command command, input, output
    @running_command = nil

    exit_status
  end

  def register(name : String, &block : ACON::Input::Interface, ACON::Output::Interface, ACON::Command -> ACON::Command::Status) : ACON::Command
    self.add(ACON::Commands::Generic.new(name, &block)).not_nil!
  end

  def render_exception(ex : Exception, output : ACON::Output::ConsoleOutputInterface) : Nil
    self.render_exception ex, output.error_output
  end

  def render_exception(ex : Exception, output : ACON::Output::Interface) : Nil
    output.puts "", :quiet

    self.do_render_exception ex, output

    if running_command = @running_command
      output.puts "<info>#{ACON::Formatter::Output.escape running_command.synopsis}</info>", :quiet
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

  def long_version : String
    "#{@name} <info>#{@version}</info>"
  end

  def help : String
    self.long_version
  end

  protected def command_name(input : ACON::Input::Interface) : String?
    @single_command ? @default_command : input.first_argument
  end

  # ameba:disable Metrics/CyclomaticComplexity
  protected def configure_io(input : ACON::Input::Interface, output : ACON::Output::Interface) : Nil
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
      if input.has_parameter?("-vvv", "--verbose=3", only_params: true) || 3 == input.parameter("--verbose", false, true)
        output.verbosity = :debug
        shell_verbosity = 3
      elsif input.has_parameter?("-vv", "--verbose=2", only_params: true) || 2 == input.parameter("--verbose", false, true)
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

  protected def do_run_command(command : ACON::Command, input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
    # TODO: Support input aware helpers.
    # TODO: Handle registering signable command listeners.

    command.run input, output

    # TODO: Handle eventing.
  end

  protected def default_input_definition : ACON::Input::Definition
    ACON::Input::Definition.new(
      ACON::Input::Argument.new("command", :required, "The command to execute"),
      ACON::Input::Option.new("help", "h", description: "Display help for the given command. When no command is given display help for the <info>#{@default_command}</info> command"),
      ACON::Input::Option.new("quiet", "q", description: "Do not output any message"),
      ACON::Input::Option.new("verbose", "v|vv|vvv", description: "Increase the verbosity of messages: 1 for normal output, 2 for more verbose output and 3 for debug"),
      ACON::Input::Option.new("version", "V", description: "Display this application version"),
      ACON::Input::Option.new("ansi", value_mode: :negatable, description: "Force (or disable --no-ansi) ANSI output", default: false),
      ACON::Input::Option.new("no-interaction", "n", description: "Do not ask any interactive question"),
    )
  end

  protected def default_commands : Array(ACON::Command)
    [
      Athena::Console::Commands::List.new,
      Athena::Console::Commands::Help.new,
    ]
  end

  protected def default_helper_set : ACON::Helper::HelperSet
    ACON::Helper::HelperSet.new(
      ACON::Helper::Formatter.new,
      ACON::Helper::Question.new
    )
  end

  # ameba:disable Metrics/CyclomaticComplexity
  protected def do_render_exception(ex : Exception, output : ACON::Output::Interface) : Nil
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

      message.split(/(?:\r?\n)/) do |line|
        self.split_string_by_width(line, width - 4) do |l|
          line_length = l.size + 4
          lines << {l, line_length}

          len = Math.max line_length, len
        end
      end

      messages = [] of String

      if !ex.is_a?(ACON::Exceptions::ConsoleException) || ACON::Output::Verbosity::VERBOSE <= output.verbosity
        if trace = ex.backtrace?.try &.first
          filename = nil
          line = nil

          if match = trace.match(/(\w+\.cr):(\d+)/)
            filename = if f = match[1]?
                         File.basename f
                       end
            line = match[2]?
          end

          messages << %(<comment>#{ACON::Formatter::Output.escape "In #{filename || "n/a"} line #{line || "n/a"}:"}</comment>)
        end
      end

      messages << (empty_line = "<error>#{" "*len}</error>")

      if messages.empty? || ACON::Output::Verbosity::VERBOSE <= output.verbosity
        messages << "<error>#{title}#{" "*(Math.max(0, len - title.size))}</error>"
      end

      lines.each do |l|
        messages << "<error>  #{ACON::Formatter::Output.escape l[0]}  #{" "*(len - l[1])}</error>"
      end

      messages << empty_line
      messages << ""

      messages.each do |m|
        output.puts m, :quiet
      end

      if (ACON::Output::Verbosity::VERBOSE <= output.verbosity) && (t = ex.backtrace?)
        output.puts "<comment>Exception trace:</comment>", :quiet

        # TODO: Improve backtrace rendering.
        t.each do |l|
          output.puts " #{l}"
        end

        output.puts "", :quiet
      end

      break unless (ex = ex.cause)
    end
  end

  private def abbreviation_suggestions(abbreviations : Array(String)) : String
    %(    #{abbreviations.join("\n    ")})
  end

  private def extract_all_namespaces(name : String) : Array(String)
    # Pop off the shortcut name of the command.
    parts = name.split(':').tap &.pop

    namespaces = [] of String

    parts.each do |p|
      namespaces << if namespaces.empty?
        p
      else
        "#{namespaces.last}:#{p}"
      end
    end

    namespaces
  end

  # ameba:disable Metrics/CyclomaticComplexity
  private def find_alternatives(name : String, collection : Enumerable(String)) : Array(String)
    alternatives = Hash(String, Int32).new
    threshold = 1_000

    collection_parts = Hash(String, Array(String)).new
    collection.each do |item|
      collection_parts[item] = item.split ':'
    end

    name.split(':').each_with_index do |sub_name, idx|
      collection_parts.each do |collection_name, parts|
        exists = alternatives.has_key? collection_name

        if exists && parts[idx]?.nil?
          alternatives[collection_name] += threshold
          next
        elsif parts[idx]?.nil?
          next
        end

        lev = Levenshtein.distance sub_name, parts[idx]

        if lev <= sub_name.size / 3 || !sub_name.empty? && parts[idx].includes? sub_name
          alternatives[collection_name] = exists ? alternatives[collection_name] + lev : lev
        elsif exists
          alternatives[collection_name] += threshold
        end
      end
    end

    collection.each do |item|
      lev = Levenshtein.distance name, item
      if lev <= name.size / 3 || item.includes? name
        alternatives[item] = (current = alternatives[item]?) ? current - lev : lev
      end
    end

    alternatives.select! { |_, lev| lev < 2 * threshold }

    alternatives.keys.sort!
  end

  private def init : Nil
    return if @initialized

    @initialized = true

    self.default_commands.each do |command|
      self.add command
    end
  end

  private def split_string_by_width(line : String, width : Int32, & : String -> Nil) : Nil
    if line.empty?
      return yield line
    end

    line.each_char.each_slice(width).map(&.join).each do |set|
      yield set
    end
  end
end
