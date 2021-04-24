class Athena::Console::Input::ARGVInput < Athena::Console::Input
  @tokens : Array(String)
  @parsed : Array(String) = [] of String

  def initialize(@tokens : Array(String) = ARGV, definition : ACON::Input::Definition? = nil)
    super definition
  end

  protected def parse : Nil
    parse_options = true
    @parsed = @tokens

    while token = @parsed.shift?
      puts "Parsing token: #{token}"

      if parse_options && token.empty?
        self.parse_argument token
      elsif parse_options && "--" == token
        parse_options = false
      elsif parse_options && token.starts_with? "--"
        self.parse_long_option token
      elsif parse_options && token.starts_with?('-') && "-" != token
        self.parse_short_option token
      else
        self.parse_argument token
      end
    end

    pp @arguments, @options
  end

  private def parse_argument(token : String) : Nil
    count = @arguments.size

    # If expecting another argument, add it.
    if @definition.has_argument? count
      argument = @definition.argument count
      @arguments[argument.name] = argument.is_array? ? [token] : token

      # If the last argument IS_ARRAY, append token to last argument.
    elsif @definition.has_argument?(count - 1) && @definition.argument(count - 1).is_array?
      argument = @definition.argument(count - 1)
      @arguments[argument.name].as(Array(String)) << token

      # TODO: Handle unexpected argument.
    else
    end
  end

  private def parse_long_option(token : String) : Nil
    name = token.lchop "--"

    if pos = name.index '='
      if (value = name[(pos + 1)..]).empty?
        @parsed.unshift value
      end

      self.add_long_option name[0, pos], value
    else
      self.add_long_option name, nil unless name.includes? '='
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

    if option.is_array?
      (@options[name] ||= Array(String | Bool | Nil).new).as(Array(String | Bool | Nil)) << value
    else
      @options[name] = value
    end
  end

  private def parse_short_option(token : String) : Nil
    name = token.lchop '-'

    if name.size > 1
      if @definition.has_shortcut?(name[0]) && @definition.option_for_shortcut(name[0]).accepts_value?
        # Option with a value & no space
        self.add_short_option name[0], name[1..]
      else
        self.parse_short_option_set name
      end
    else
      self.add_short_option name, nil
    end
  end

  private def parse_short_option_set(name : String) : Nil
    length = name.size
    name.each_char_with_index do |char, idx|
      raise "The -#{char} option does not exist." unless @definition.has_shortcut? char

      option = @definition.option_for_shortcut char

      if option.accepts_value?
        self.add_long_option option.name, idx == length - 1 ? nil : name[(idx + 1)..]

        break
      else
        self.add_long_option option.name, nil
      end
    end
  end

  private def add_short_option(name : String | Char, value : String?) : Nil
    name = name.to_s

    raise "The -#{name} option does not exist." if !@definition.has_shortcut? name

    self.add_long_option @definition.option_for_shortcut(name).name, value
  end
end
