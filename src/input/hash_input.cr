class Athena::Console::Input::HashInput < Athena::Console::Input
  @parameters : Hash(String, String)

  def initialize(@parameters : Hash(String, String), definition : ACON::Input::Definition? = nil)
    super definition
  end

  def first_argument : String?
    @parameters.each do |name, value|
      next if name.starts_with? '-'

      return value
    end

    nil
  end

  def has_parameter?(*values : String, only_params : Bool = false) : Bool
    @parameters.each do |name, value|
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
      return if "--" == key

      if key.starts_with? "--"
        self.add_long_option key.lchop "--", value
      elsif key.starts_with? '-'
        self.add_short_option key.lchop '-', value
      else
        self.add_argument key, value
      end
    end
  end

  private def add_long_option(name : String, value : String?) : Nil
    if !@definition.has_option?(name)
      # TODO: Handle negation stuff
    end

    option = @definition.option name

    if !value.nil? && !option.accepts_value?
      raise "The --#{option.name} option does not accept a value."
    end

    if value.nil?
      raise "The --#{option.name} option requires a value." if option.value_required?
      value = true if !option.is_array? && !option.value_optional?
    end

    @options[name] = value
  end

  private def add_short_option(name : String, value : String?) : Nil
    name = name.to_s

    raise "The -#{name} option does not exist." if !@definition.has_shortcut? name

    self.add_long_option @definition.option_for_shortcut(name).name, value
  end
end
