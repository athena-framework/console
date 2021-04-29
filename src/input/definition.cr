class Athena::Console::Input::Definition
  getter options : Hash(String, ACON::Input::Option) = Hash(String, ACON::Input::Option).new
  getter arguments : Hash(String, ACON::Input::Argument) = Hash(String, ACON::Input::Argument).new

  @last_array_argument : ACON::Input::Argument? = nil
  @last_optional_argument : ACON::Input::Argument? = nil

  @shortcuts = Hash(String, String).new
  @negations = Hash(String, String).new

  getter required_argument_count : Int32 = 0

  def self.new(definition : Hash(String, ACON::Input::Option) | Hash(String, ACON::Input::Argument)) : self
    new definition.values
  end

  def self.new(*definitions : ACON::Input::Argument | ACON::Input::Option) : self
    new definitions.to_a
  end

  def initialize(definition : Array(ACON::Input::Argument | ACON::Input::Option) = Array(ACON::Input::Argument | ACON::Input::Option).new)
    self.definition = definition
  end

  def <<(argument : ACON::Input::Argument) : Nil
    raise ACON::Exceptions::Logic.new "An argument with the name '#{argument.name}' already exists." if @arguments.has_key?(argument.name)

    if (last_array_argument = @last_array_argument)
      raise ACON::Exceptions::Logic.new "Cannot add a required argument '#{argument.name}' after Array argument '#{last_array_argument.name}'."
    end

    if argument.required? && (last_optional_argument = @last_optional_argument)
      raise ACON::Exceptions::Logic.new "Cannot add required argument '#{argument.name}' after the optional argument '#{last_optional_argument.name}'."
    end

    if argument.is_array?
      @last_array_argument = argument
    end

    if argument.required?
      @required_argument_count += 1
    else
      @last_optional_argument = argument
    end

    @arguments[argument.name] = argument
  end

  def <<(option : ACON::Input::Option) : Nil
    if self.has_option?(option.name) && option != self.option(option.name)
      raise ACON::Exceptions::Logic.new "An option named '#{option.name}' already exists."
    end

    if self.has_negation?(option.name)
      raise ACON::Exceptions::Logic.new "An option named '#{option.name}' already exists."
    end

    if shortcut = option.shortcut
      shortcut.split('|', remove_empty: true) do |s|
        if self.has_shortcut?(s) && option != self.option_for_shortcut(s)
          raise ACON::Exceptions::Logic.new "An option with shortcut '#{s}' already exists."
        end
      end
    end

    @options[option.name] = option

    if shortcut
      shortcut.split('|', remove_empty: true) do |s|
        @shortcuts[s] = option.name
      end
    end

    if option.negatable?
      negated_name = "no-#{option.name}"

      raise ACON::Exceptions::Logic.new "An option named '#{negated_name}' already exists." if self.has_option? negated_name

      @negations[negated_name] = option.name
    end
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
    @required_argument_count = 0
    @last_array_argument = nil
    @last_optional_argument = nil

    self.<< arguments
  end

  def argument(name : String | Int32) : ACON::Input::Argument
    raise ACON::Exceptions::InvalidArgument.new "The argument '#{name}' does not exist." unless self.has_argument? name

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

  def argument_defaults
    @arguments.to_h do |(name, arg)|
      {name, arg.default}
    end
  end

  def options=(options : Array(ACON::Input::Option)) : Nil
    @options.clear
    @shortcuts.clear
    @negations.clear

    self.<< options
  end

  def option(name : String | Int32) : ACON::Input::Option
    raise ACON::Exceptions::InvalidArgument.new "The '--#{name}' option does not exist." unless self.has_option? name

    case name
    in String then @options[name]
    in Int32  then @options.values[name]
    end
  end

  def option_defaults
    @options.to_h do |(name, opt)|
      {name, opt.default}
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

  def negation_to_name(name : String) : String
    raise ACON::Exceptions::InvalidArgument.new "The '--#{name}' option does not exist." unless self.has_negation? name

    @negations[name]
  end

  def option_for_shortcut(shortcut : String | Char) : ACON::Input::Option
    self.option self.shortcut_to_name shortcut.to_s
  end

  def synopsis(short : Bool = false) : String
    elements = [] of String

    if short && !@options.empty?
      elements << "[options]"
    elsif !short
      @options.each_value do |opt|
        value = ""

        if opt.accepts_value?
          value = sprintf(
            " %s%s%s",
            opt.value_optional? ? "[" : "",
            opt.name.upcase,
            opt.value_optional? ? "]" : "",
          )
        end

        shortcut = (s = opt.shortcut) ? sprintf("-%s|", s) : ""
        negation = opt.negatable? ? sprintf("|--no-%s", opt.name) : ""

        elements << "[#{shortcut}--#{opt.name}#{value}#{negation}]"
      end
    end

    if !elements.empty? && !@arguments.empty?
      elements << "[--]"
    end

    tail = ""

    @arguments.each_value do |arg|
      element = "<#{arg.name}>"
      element += "..." if arg.is_array?

      unless arg.required?
        element = "[#{element}"
        tail += "]"
      end

      elements << element
    end

    %(#{elements.join " "}#{tail})
  end

  protected def shortcut_to_name(shortcut : String) : String
    raise ACON::Exceptions::InvalidArgument.new "The '-#{shortcut}' option does not exist." unless self.has_shortcut? shortcut

    @shortcuts[shortcut]
  end
end
