class Athena::Console::Commands::List < Athena::Console::Command
  protected def configure : Nil
    self
      .name("list")
      .definition(
        ACON::Input::Argument.new("namespace", :optional, "Only list commands in this namespace"),
        ACON::Input::Option.new("raw", nil, :none, "To output raw command list"),
        ACON::Input::Option.new("format", nil, :required, "The output format (txt)", "txt"),
        ACON::Input::Option.new("short", nil, :none, "To skip describing command's arguments"),
      )
      .description("List commands")
  end

  protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
    ACON::Helper::Descriptor.new.describe(
      output,
      self.application,
      ACON::Descriptor::Context.new(
        format: input.option("format", String),
        raw_text: input.option("raw", Bool),
        namespace: input.argument("namespace", String?),
        short: input.option("short", Bool)
      )
    )

    ACON::Command::Status::SUCCESS
  end
end
