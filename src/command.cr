abstract class Athena::Console::Command
  enum Status
    SUCCESS = 0
    FAILURE = 1
    INVALID = 2
  end

  enum Synopsis
    SHORT
    LONG
  end

  @@default_name : String? = nil
  @@default_description : String? = nil

  def self.default_name : String?
    # TODO: Support reading name from annotation.

    @@default_name
  end

  def self.default_description : String?
    # TODO: Support reading description from annotation.

    @@default_description
  end

  getter! name : String
  getter description : String = ""
  property help : String = ""

  getter! application : ACON::Application
  property aliases : Array(String) = [] of String
  setter process_title : String? = nil
  property helper_set : ACON::Helper::HelperSet? = nil
  getter? hidden : Bool = false
  getter usages : Array(String) = [] of String

  @definition : ACON::Input::Definition = ACON::Input::Definition.new
  @full_definition : ACON::Input::Definition? = nil
  @ignore_validation_errors : Bool = false
  @synopsis = Hash(ACON::Command::Synopsis, String).new

  def initialize(name : String? = nil)
    if n = (name || self.class.default_name)
      self.name n
    end

    if (@description.empty?) && (description = self.class.default_description)
      self.description description
    end

    self.configure
  end

  def aliases(*aliases : String) : self
    self.aliases aliases.to_a
  end

  def aliases(aliases : Enumerable(String)) : self
    aliases.each &->validate_name(String)

    @aliases = aliases

    self
  end

  def application=(@application : ACON::Application? = nil) : Nil
    if application = @application
      @helper_set = application.helper_set
    else
      @helper_set = nil
    end

    @full_definition = nil
  end

  def argument(name : String, mode : ACON::Input::Argument::Mode = :optional, description : String = "", default = nil) : self
    @definition << ACON::Input::Argument.new name, mode, description, default

    if full_definition = @full_definition
      full_definition << ACON::Input::Argument.new name, mode, description, default
    end

    self
  end

  def definition : ACON::Input::Definition
    @full_definition || self.native_definition
  end

  def definition(@definition : ACON::Input::Definition) : self
    @full_definition = nil

    self
  end

  def definition(*definitions : ACON::Input::Argument | ACON::Input::Option) : self
    self.definition definitions.to_a
  end

  def definition(definition : Array(ACON::Input::Argument | ACON::Input::Option)) : self
    @definition.definition = definition

    @full_definition = nil

    self
  end

  def description(@description : String) : self
    self
  end

  def name(name : String) : self
    self.validate_name name

    @name = name

    self
  end

  def help(@help : String) : self
    self
  end

  def hidden(@hidden : Bool) : self
    self
  end

  def option(name : String, shotcut : String? = nil, value_mode : ACON::Input::Option::Value = :none, description : String = "", default = nil) : self
    @definition << ACON::Input::Option.new name, shotcut, value_mode, description, default

    if full_definition = @full_definition
      full_definition << ACON::Input::Option.new name, shotcut, value_mode, description, default
    end

    self
  end

  def processed_help : String
    is_single_command = (application = @application) && application.single_command?
    prog_name = Path.new(PROGRAM_NAME).basename
    full_name = is_single_command ? prog_name : "#{prog_name} #{@name}"

    processed_help = self.help || self.description

    { {"%command.name%", @name}, {"%command.full_name%", full_name} }.each do |(placeholder, replacement)|
      processed_help = processed_help.gsub placeholder, replacement
    end

    processed_help
  end

  def synopsis(short : Bool = false) : String
    key = short ? Synopsis::SHORT : Synopsis::LONG

    unless @synopsis.has_key? key
      @synopsis[key] = "#{@name} #{@definition.synopsis short}".strip
    end

    @synopsis[key]
  end

  def usage(usage : String) : self
    unless usage.starts_with? @name
      usage = "#{@name} #{usage}"
    end

    @usages << usage

    self
  end

  def ignore_validation_errors : Nil
    @ignore_validation_errors = true
  end

  def enabled? : Bool
    true
  end

  def run(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
    self.merge_application_definition

    begin
      input.bind self.definition
    rescue ex : ACON::Exceptions::ConsoleException
      raise ex unless @ignore_validation_errors
    end

    self.setup input, output

    # TODO: Allow setting process title

    if input.interactive?
      self.interact input, output
    end

    # TODO: Set `command` argument if ran directly

    input.validate

    self.execute input, output
  end

  protected def merge_application_definition(merge_args : Bool = true) : Nil
    return unless (application = @application)

    # TODO: Figure out if there is a better way to structure/store
    # the data to remove the .values call.
    full_definition = ACON::Input::Definition.new
    full_definition.options = @definition.options.values
    full_definition << application.definition.options.values

    if merge_args
      full_definition.arguments = application.definition.arguments.values
      full_definition << @definition.arguments.values
    else
      full_definition.arguments = @definition.arguments.values
    end

    @full_definition = full_definition
  end

  protected def native_definition
    @definition
  end

  protected abstract def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status

  protected def configure : Nil
  end

  protected def interact(input : ACON::Input::Interface, output : ACON::Output::Interface) : Nil
  end

  protected def setup(input : ACON::Input::Interface, output : ACON::Output::Interface) : Nil
  end

  private def validate_name(name : String) : Nil
    raise ArgumentError.new "Command name '#{name}' is invalid." unless name.matches? /^[^:]++(:[^:]++)*$/
  end
end
