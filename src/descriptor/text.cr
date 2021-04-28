class Athena::Console::Descriptor::Text < Athena::Console::Descriptor
  def describe(output : ACON::Output::Interface, object : ACON::Application, context : ACON::Descriptor::ListContext) : Nil
    description = ACON::Descriptor::Application.new object, context.namespace

    commands = description.commands.values

    if context.raw_text?
      width = self.width commands

      commands.each do |command|
        self.write_text output, sprintf("%-#{width}s %s", command.name, command.description)
        self.write_text output, "\n"
      end
    else
    end
  end

  private def width(commands : Array(ACON::Command)) : Int32
    widths = Array(Int32).new

    commands.each do |command|
      widths << command.name.not_nil!.size

      command.aliases.each do |a|
        widths << a.size
      end
    end

    widths.empty? ? 0 : widths.max + 2
  end

  private def write_text(output : ACON::Output::Interface, content : String, context : ACON::Descriptor::ListContext? = nil) : Nil
    unless ctx = context
      return self.write output, content, true
    end

    raw_output = true

    ctx.raw_output?.try do |ro|
      raw_output = ro
    end

    self.write(
      output,
      content,
      raw_output
    )
  end
end

"name           desc"
