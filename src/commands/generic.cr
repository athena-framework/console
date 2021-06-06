class Athena::Console::Commands::Generic < Athena::Console::Command
  alias Proc = ::Proc(ACON::Input::Interface, ACON::Output::Interface, ACON::Command, ACON::Command::Status)

  def initialize(name : String, &@callback : ACON::Commands::Generic::Proc)
    super name
  end

  protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
    @callback.call input, output, self
  end
end
