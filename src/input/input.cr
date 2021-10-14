require "./interface"
require "./streamable"

abstract class Athena::Console::Input
  include Athena::Console::Input::Streamable

  private abstract struct AbstractValue
    def self.from_value(value : T) : self forall T
      case value
      when AbstractValue then value
      when Nil           then NilValue.new
      when String        then StringValue.new value
      when Number        then NumberValue.new value
      when Bool          then BoolValue.new value
      when Array         then ArrayValue.from_array value
      else
        raise "Unsupported type: #{T}."
      end
    end

    def get(as : Array(T).class) forall T
      Array(T).new
    end

    def get(as : T.class) forall T
      value = self.value

      raise "'#{value}' is not a valid #{T}." unless value.is_a? T

      value.as T
    end

    def to_s(io : IO) : Nil
      self.value.to_s io
    end

    abstract def value
  end

  record BoolValue < AbstractValue, value : Bool do
    def get(as : Bool.class) : Bool
      @value
    end
  end

  record NumberValue < AbstractValue, value : Number::Primitive do
    {% for type in Number::Primitive.union_types %}
      def get(as : {{type.id}}.class) : {{type.id}}
        {{type.id}}.new @value
      end
    {% end %}
  end

  record StringValue < AbstractValue, value : String do
    def get(as : Bool.class) : Bool
      @value == "true"
    end

    {% for type in Number::Primitive.union_types %}
      def get(as : {{type.id}}.class) : {{type.id}}
        {{type.id}}.new @value
      end

      def get(as : {{type.id}}?.class) : {{type.id}}?
        self.get {{type.id}}
      end
    {% end %}
  end

  record ArrayValue < AbstractValue, value : Array(AbstractValue) do
    def self.from_array(array : Array) : self
      new(array.map { |item| AbstractValue.from_value item })
    end

    def self.new(value)
      new [AbstractValue.from_value value]
    end

    def self.new
      new [] of AbstractValue
    end

    def <<(value)
      @value << AbstractValue.from_value value
    end

    def get(as : Array(T).class) : Array(T) forall T
      @value.map &.get(T)
    end

    def resolve
      self.value.map &.resolve
    end

    def to_s(io : IO) : Nil
      @value.join io, ','
    end
  end

  record NilValue < AbstractValue do
    def value : Nil; end
  end

  alias InputTypes = String | Bool | Nil | Number::Primitive
  alias InputType = InputTypes | Array(InputTypes)
  alias HashType = ::Hash(String, InputType)

  property stream : IO? = nil

  property? interactive : Bool = true

  @arguments = ::Hash(String, AbstractValue).new
  @definition : ACON::Input::Definition
  @options = HashType.new

  def initialize(definition : ACON::Input::Definition? = nil)
    if definition.nil?
      @definition = ACON::Input::Definition.new
    else
      @definition = definition
      self.bind definition
      self.validate
    end
  end

  def argument(name : String) : String?
    raise ACON::Exceptions::InvalidArgument.new "The '#{name}' argument does not exist." unless @definition.has_argument? name

    value = if @arguments.has_key? name
              @arguments[name]
            else
              @definition.argument(name).default
            end

    case value
    when Nil then nil
    else
      value.to_s
    end
  end

  def argument(name : String, type : T.class) : T forall T
    raise ACON::Exceptions::InvalidArgument.new "The '#{name}' argument does not exist." unless @definition.has_argument? name

    {% unless T.nilable? %}
      if !@definition.argument(name).required? && @definition.argument(name).default.nil?
        raise ACON::Exceptions::Logic.new "Cannot cast optional argument '#{name}' to non-nilable type #{T}."
      end
    {% end %}

    if @arguments.has_key? name
      return @arguments[name].get T
    end

    @definition.argument(name).default T
  end

  def set_argument(name : String, value : String | Array(String) | Nil) : Nil
    raise ACON::Exceptions::InvalidArgument.new "The '#{name}' argument does not exist." unless @definition.has_argument? name

    @arguments[name] = AbstractValue.from_value value
  end

  def arguments : ::Hash
    @definition.argument_defaults.merge(self.resolve @arguments)
  end

  def has_argument?(name : String) : Bool
    @definition.has_argument? name
  end

  def option(name : String)
    if @definition.has_negation?(name)
      self.option(@definition.negation_to_name(name)).try do |v|
        return !v
      end

      return
    end

    raise ACON::Exceptions::InvalidArgument.new "The '#{name}' option does not exist." unless @definition.has_option? name

    if @options.has_key? name
      return @options[name]
    end

    @definition.option(name).default
  end

  def option(name : String, type : T.class) : T forall T
    self.option(name).as T
  end

  def set_option(name : String, value : String | Array(String) | Bool | Nil) : Nil
    if @definition.has_negation?(name)
      @options[@definition.negation_to_name(name)] = !value

      return
    end

    raise ACON::Exceptions::InvalidArgument.new "The '#{name}' option does not exist." unless @definition.has_option? name

    @options[name] = value
  end

  def options : ::Hash
    @definition.option_defaults.merge @options
  end

  def has_option?(name : String) : Bool
    @definition.has_option?(name) || @definition.has_negation?(name)
  end

  def bind(definition : ACON::Input::Definition) : Nil
    @arguments.clear
    @options.clear
    @definition = definition

    self.parse
  end

  protected abstract def parse : Nil

  def validate : Nil
    missing_args = @definition.arguments.keys.select do |arg|
      !@arguments.has_key?(arg) && @definition.argument(arg).required?
    end

    raise ACON::Exceptions::ValidationFailed.new %(Not enough arguments (missing: '#{missing_args.join(", ")}').) unless missing_args.empty?
  end

  private def resolve(hash : ::Hash(String, AbstractValue)) : ::Hash
    hash.transform_values do |value|
      case value
      when ArrayValue
        value.value.map &.value
      else
        value.value
      end
    end
  end
end
