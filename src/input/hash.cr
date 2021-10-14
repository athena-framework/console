class Athena::Console::Input::Hash < Athena::Console::Input
  @parameters : HashType

  def self.new(*args : InputType) : self
    new args
  end

  def self.new(args : Enumerable(InputType)) : self
    hash = HashType.new

    args.each do |arg|
      hash[arg] = nil
    end

    new hash
  end

  def self.new(**args : InputType) : self
    new args.to_h.transform_keys(&.to_s).transform_values(&.as(InputType))
  end

  def initialize(@parameters : HashType = HashType.new, definition : ACON::Input::Definition? = nil)
    super definition
  end

  def first_argument : String?
    @parameters.each do |name, value|
      next if name.starts_with? '-'

      return value.as(String)
    end

    nil
  end

  def has_parameter?(*values : String, only_params : Bool = false) : Bool
    @parameters.each do |name, value|
      value = name unless value.is_a? Number
      return false if only_params && "--" == value
      return true if values.includes? value
    end

    false
  end

  def parameter(value : String, default : _ = false, only_params : Bool = false)
    @parameters.each do |name, v|
      return default if only_params && ("--" == name || "--" == value)
      return v if value == name
    end

    default
  end

  protected def parse : Nil
    @parameters.each do |name, value|
      return if "--" == name

      if name.starts_with? "--"
        self.add_long_option name.lchop("--"), value
      elsif name.starts_with? '-'
        self.add_short_option name.lchop('-'), value
      else
        self.add_argument name, value
      end
    end
  end

  private def add_argument(name : String, value : InputType) : Nil
    raise ACON::Exceptions::InvalidArgument.new "The '#{name}' argument does not exist." if !@definition.has_argument? name

    @arguments[name] = AbstractValue.from_value value
  end

  private def add_long_option(name : String, value : InputType) : Nil
    unless @definition.has_option?(name)
      raise ACON::Exceptions::InvalidOption.new "The '--#{name}' option does not exist." unless @definition.has_negation? name

      option_name = @definition.negation_to_name name
      @options[option_name] = false

      return
    end

    option = @definition.option name

    if value.nil?
      raise ACON::Exceptions::InvalidOption.new "The '--#{option.name}' option requires a value." if option.value_required?
      value = true if !option.is_array? && !option.value_optional?
    end

    @options[name] = value
  end

  private def add_short_option(name : String, value : InputType) : Nil
    name = name.to_s

    raise ACON::Exceptions::InvalidOption.new "The '-#{name}' option does not exist." if !@definition.has_shortcut? name

    self.add_long_option @definition.option_for_shortcut(name).name, value
  end
end
