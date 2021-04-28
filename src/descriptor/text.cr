class Athena::Console::Descriptor::Text < Athena::Console::Descriptor
  protected def describe(application : ACON::Application, context : ACON::Descriptor::Context) : Nil
    described_namespace = context.namespace
    description = ACON::Descriptor::Application.new application, context.namespace

    commands = description.commands.values

    if context.raw_text?
      width = self.width commands

      commands.each do |command|
        self.write_text sprintf("%-#{width}s %s", command.name, command.description)
        self.write_text "\n"
      end

      return
    end

    self.write_text "#{application.help}\n\n", context

    self.write_text "<comment>Usage:</comment>\n", context
    self.write_text "  command [options] [arguments]\n\n", context

    self.describe ACON::Input::Definition.new(application.definition.options), context

    self.write_text "\n"
    self.write_text "\n"

    commands = description.commands
    namespaces = description.namespaces

    if described_namespace && !namespaces.empty?
      # Ensure all alias commands are included when describing a specific namespace.
      # TODO: Do this.
    end

    width = self.width(
      namespaces.values.flat_map do |n|
        n[:commands] | commands.keys
      end.uniq!
    )

    if described_namespace
      self.write_text "<comment>Available commands for the #{described_namespace} namespace:</comment>", context
    else
      self.write_text "<comment>Available commands:</comment>"
    end

    namespaces.each_value do |namespace|
      namespace[:commands].select! { |c| commands.has_key? c }

      next if namespace[:commands].empty?

      if !described_namespace && namespace[:id] != ACON::Descriptor::Application::GLOBAL_NAMESPACE
        self.write_text "\n"
        self.write_text " <comment>#{namespace[:id]}</comment>"
      end

      namespace[:commands].each do |name|
        self.write_text "\n"
        spacing_width = width - name.size
        command = commands[name]
        command_aliases = name === command.name ? "" : ""

        self.write_text "  <info>#{name}</info>#{" " * spacing_width}#{command_aliases}#{command.description}"
      end
    end

    self.write_text "\n"
  end

  protected def describe(argument : ACON::Input::Argument, context : ACON::Descriptor::Context) : Nil
    # TODO: Implement this.
  end

  protected def describe(command : ACON::Command, context : ACON::Descriptor::Context) : Nil
    command.merge_application_definition false

    if description = command.description.presence
      self.write_text "<comment>Description:</comment>", context
      self.write_text "\n"
      self.write_text "  #{description}"
      self.write_text "\n\n"
    end

    self.write_text "<comment>Usage:</comment>", context

    # self.output.puts command.synopsis
  end

  protected def describe(definition : ACON::Input::Definition, context : ACON::Descriptor::Context) : Nil
    total_width = self.calculate_total_width_for_options definition.options

    definition.arguments.each_value do |arg|
      total_width = Math.max total_width, arg.name.size
    end

    unless definition.arguments.empty?
      self.write_text "<comment>Arguments:</comment>"
      self.write_text "\n"

      definition.arguments.each_value do |arg|
        self.describe arg, context.copy_with total_width: total_width
        self.write_text "\n"
      end
    end

    if !definition.arguments.empty? && !definition.options.empty?
      self.write_text "\n"
    end

    unless definition.options.empty?
      later_options = [] of ACON::Input::Option

      self.write_text "<comment>Options:</comment>"

      definition.options.each_value do |option|
        if (option.shortcut || "").size > 1
          later_options << option
          next
        end

        self.write_text "\n"
        self.describe option, context.copy_with total_width: total_width
      end

      later_options.each do |option|
        self.write_text "\n"
        self.describe option, context.copy_with total_width: total_width
      end
    end
  end

  protected def describe(option : ACON::Input::Option, context : ACON::Descriptor::Context) : Nil
    if option.accepts_value? && !option.default.nil? && !option.default.is_a?(Array)
      default = "<comment> [default: #{option.default}]</comment>"
    else
      default = ""
    end

    value = ""
    if option.accepts_value?
      value = "=#{option.name.upcase}"

      if option.value_optional?
        value = "[#{value}]"
      end
    end

    total_width = context.total_width || self.calculate_total_width_for_options [option]
    synopsis = sprintf(
      "%s%s",
      (s = option.shortcut) ? sprintf("-%s, ", s) : "    ",
      (option.negatable? ? "--%<name>s|--no-%<name>s" : "--%<name>s%<value>s") % {name: option.name, value: value}
    )

    spacing_width = total_width - synopsis.size

    self.write_text(
      sprintf(
        "  <info>%s</info>  %s%s%s%s",
        synopsis,
        " " * spacing_width,
        option.description.gsub(/\s*[\r\n]\s*/, "\n#{" " * (total_width + 4)}"),
        default,
        option.is_array? ? "<comment> (multiple values allowed)</comment>" : ""
      )
    )
  end

  private def width(commands : Array(ACON::Command) | Array(String)) : Int32
    widths = Array(Int32).new

    commands.each do |command|
      case command
      in ACON::Command
        widths << command.name.not_nil!.size

        command.aliases.each do |a|
          widths << a.size
        end
      in String
        widths << command.size
      end
    end

    widths.empty? ? 0 : widths.max + 2
  end

  private def calculate_total_width_for_options(options : Hash(String, ACON::Input::Option)) : Int32
    self.calculate_total_width_for_options options.values
  end

  private def calculate_total_width_for_options(options : Array(ACON::Input::Option)) : Int32
    options.max_of do |o|
      name_length = 1 + Math.max((o.shortcut || "").size, 1) + 4 + o.name.size

      if o.negatable?
        name_length += 6 + o.name.size
      elsif o.accepts_value?
        name_length += 1 + o.name.size + (o.value_optional? ? 2 : 0)
      end

      name_length
    end
  end

  private def write_text(content : String, context : ACON::Descriptor::Context? = nil) : Nil
    unless ctx = context
      return self.write content, true
    end

    raw_output = true

    ctx.raw_output?.try do |ro|
      raw_output = ro
    end

    self.write(
      content,
      raw_output
    )
  end
end
