abstract class IOCommand < ACON::Command
  getter! input : ACON::Input::Interface
  getter! output : ACON::Output::Interface

  protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
    @input = input
    @output = output

    ACON::Command::Status::SUCCESS
  end
end
