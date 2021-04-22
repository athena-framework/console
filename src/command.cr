abstract class Athena::Console::Command
  enum Status
    Success
    Failure
    Invalid
  end

  @@default_name : String? = nil

  def self.default_name : String?
    # TODO: Support reading name from annotation.

    @@default_name || nil
  end

  getter name : String? = nil

  def initialize(name : String? = nil)
    if n = (name || @@default_name)
      self.name = n
    end

    self.configure
  end

  def name=(name : String) : self
    self.validate_name name

    @name = name

    self
  end

  abstract def execute(input : IO, output : IO) : ACON::Command::Status

  protected def configure : Nil
  end

  protected def interact(input : IO, output : IO) : Nil
  end

  protected def setup(input : IO, output : IO) : Nil
  end

  private def validate_name(name : String) : Nil
    raise ArgumentError.new "Command name '#{name}' is invalid." unless name.matches? /^[^:]++(:[^:]++)*$/
  end
end
