require "./interface"

struct Athena::Console::Loader::Factory
  include Athena::Console::Loader::Interface

  @factories : Hash(String, Proc(ACON::Command))

  def initialize(@factories : Hash(String, Proc(ACON::Command))); end

  # :inherit:
  def get(name : String) : ACON::Command
    if factory = @factories[name]?
      factory.call
    else
      raise ACON::Exceptions::CommandNotFound.new "Command '#{name}' does not exist."
    end
  end

  # :inherit:
  def has?(name : String) : Bool
    @factories.has_key? name
  end

  # :inherit:
  def names : Array(String)
    @factories.keys
  end
end
