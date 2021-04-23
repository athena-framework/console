class Athena::Console::Formatter::OutputFormatterStyleStack
  property empty_style : ACON::Formatter::OutputFormatterStyleInterface

  @styles = Array(ACON::Formatter::OutputFormatterStyleInterface).new

  def initialize(@empty_style : ACON::Formatter::OutputFormatterStyleInterface = ACON::Formatter::OutputFormatterStyle.new)
    self.reset
  end

  def reset : Nil
    @styles.clear
  end

  def <<(style : ACON::Formatter::OutputFormatterStyleInterface) : Nil
    @styles << style
  end

  def pop(style : ACON::Formatter::OutputFormatterStyleInterface? = nil) : ACON::Formatter::OutputFormatterStyleInterface
    return @empty_style if @styles.empty?

    return @styles.pop if style.nil?

    @styles.reverse_each do |stacked_style|
      if style.apply("") == stacked_style.apply("")
        @styles.delete style

        return style
      end
    end

    raise ArgumentError.new "Provided style is not present in the stack."
  end

  def current : ACON::Formatter::OutputFormatterStyleInterface
    @styles.last? || @empty_style
  end
end
