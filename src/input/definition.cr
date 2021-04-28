class Athena::Console::Input::Definition
  getter options : Hash(String, ACON::Input::Option) = Hash(String, ACON::Input::Option).new
  getter arguments : Hash(String, ACON::Input::Argument) = Hash(String, ACON::Input::Argument).new

  @last_array_argument : ACON::Input::Argument? = nil
  @last_optional_argument : ACON::Input::Argument? = nil

  @shortcuts = Hash(String, String).new
  @negations = Hash(String, String).new

  getter required_count : Int32 = 0

  def self.new(definition : Hash(String, ACON::Input::Option) | Hash(String, ACON::Input::Argument)) : self
    new definition.values
  end

  def self.new(*definitions : ACON::Input::Argument | ACON::Input::Option) : self
    new definitions.to_a
  end

  def initialize(definition : Array(ACON::Input::Argument | ACON::Input::Option)? = nil)
    return unless definition

    self.definition = definition
  end

  def <<(argument : ACON::Input::Argument) : Nil
    raise "An argument with the name #{argument.name} already exists." if @arguments.has_key?(argument.name)
    raise "Cannot add a required argument after an Array argument." unless @last_array_argument.nil?
    if argument.required? && (last_optional_argument = @last_optional_argument)
      raise "Cannot add required argument #{argument.name} after the optional argument #{last_optional_argument.name}."
    end

    if argument.is_array?
      @last_array_argument = argument
    end

    if argument.required?
      @required_count += 1
    else
      @last_optional_argument = argument
    end

    @arguments[argument.name] = argument
  end

  def <<(option : ACON::Input::Option) : Nil
    # TODO: Validate input

    @options[option.name] = option

    if shortcut = option.shortcut
      shortcut.split('|', remove_empty: true) do |s|
        @shortcuts[s] = option.name
      end
    end

    # TODO: Register negations
  end

  def <<(arguments : Array(ACON::Input::Argument | ACON::Input::Option)) : Nil
    arguments.each do |arg|
      self.<< arg
    end
  end

  def definition=(definition : Array(ACON::Input::Argument | ACON::Input::Option)) : Nil
    arguments = Array(ACON::Input::Argument).new
    options = Array(ACON::Input::Option).new

    definition.each do |d|
      case d
      in ACON::Input::Argument then arguments << d
      in ACON::Input::Option   then options << d
      end
    end

    self.arguments = arguments
    self.options = options
  end

  def arguments=(arguments : Array(ACON::Input::Argument)) : Nil
    @arguments.clear
    @required_count = 0
    @last_array_argument = nil
    @last_optional_argument = nil

    self.<< arguments
  end

  def argument(name : String | Int32) : ACON::Input::Argument
    case name
    in String then @arguments[name]
    in Int32  then @arguments.values[name]
    end
  end

  def has_argument?(name : String | Int32) : Bool
    case name
    in String then @arguments.has_key? name
    in Int32  then !@arguments.values.[name]?.nil?
    end
  end

  def argument_count : Int32
    !@last_array_argument.nil? ? Int32::MAX : @arguments.size
  end

  def argument_defaults : Array(String | Array(String) | Bool)
    @arguments.to_h do |(name, arg)|
      {name, arg.default}
    end
  end

  def options=(options : Array(ACON::Input::Option)) : Nil
    @options.clear
    @shortcuts = Hash(String, String).new
    @negations = Hash(String, String).new

    self.<< options
  end

  def option(name : String | Int32) : ACON::Input::Option
    case name
    in String then @options[name]
    in Int32  then @options.values[name]
    end
  end

  def has_option?(name : String | Int32) : Bool
    case name
    in String then @options.has_key? name
    in Int32  then !@options.values.[name]?.nil?
    end
  end

  def has_shortcut?(name : String | Char) : Bool
    @shortcuts.has_key? name.to_s
  end

  def has_negation?(name : String | Char) : Bool
    @negations.has_key? name.to_s
  end

  def option_for_shortcut(shortcut : String | Char) : ACON::Input::Option
    self.option self.shortcut_to_name shortcut.to_s
  end

  protected def shortcut_to_name(shortcut : String) : String
    @shortcuts[shortcut]
  end
end
