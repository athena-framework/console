abstract class Athena::Console::Command
  enum Status
    SUCCESS = 0
    FAILURE = 1
    INVALID = 2
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

  getter name : String? = nil
  getter description : String = ""
  getter help : String = ""

  getter application : ACON::Application? = nil
  property aliases : Array(String) = [] of String

  @definition : ACON::Input::Definition
  @full_definition : ACON::Input::Definition? = nil

  def initialize(name : String? = nil)
    @definition = ACON::Input::Definition.new

    if n = (name || self.class.default_name)
      self.name n
    end

    if (@description.empty?) && (description = self.class.default_description)
      self.description description
    end

    self.configure
  end

  def application=(@application : ACON::Application? = nil) : Nil
    if application = @application
      # TODO: Set helper set to the application's
    else
      # TODO: Otherwise nil out the helper set
    end

    @full_definition = nil
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

  def enabled? : Bool
    true
  end

  def run(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
    self.merge_application_definition

    ACON::Command::Status::SUCCESS
  end

  protected def merge_application_definition(merge_args : Bool = true) : Nil
    return if (application = @application)

    full_definition = ACON::Input::Definition.new
    # full_definition.options = @definition.options

    @full_definition = full_definition
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
