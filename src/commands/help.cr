class Athena::Console::Commands::Help < Athena::Console::Command
  setter command : ACON::Command? = nil

  protected def configure : Nil
    self
      .name("help")
      .definition(
        ACON::Input::Argument.new("command_name", :optional, "The command name", "help"),
        ACON::Input::Option.new("raw", nil, :none, "To output raw command help"),
        ACON::Input::Option.new("format", nil, :required, "The output format (txt)", "txt"),
      )
      .description("Display help for a command")
      .help(
        <<-HELP
        The <info>%command.name%</info> command displays help for a given command:

          <info>%command.full_name% list</info>

        You can also output the help in other formats by using the <comment>--format</comment> option:

          <info>%command.full_name% --format=xml list</info>

        To display the list of available commands, please use the <info>list</info> command.
        HELP
      )
  end

  protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
    if @command.nil?
      @command = self.application.find input.argument("command_name", String)
    end

    ACON::Helper::Descriptor.new.describe(
      output,
      @command.not_nil!,
      ACON::Descriptor::Context.new(
        format: input.option("format", String),
        raw_text: input.option("raw", Bool),
      )
    )

    @command = nil

    ACON::Command::Status::SUCCESS
  end
end
