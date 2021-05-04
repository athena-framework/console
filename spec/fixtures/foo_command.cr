class FooCommand < ACON::Command
  getter input : ACON::Input::Interface? = nil
  getter output : ACON::Output::Interface? = nil

  protected def configure : Nil
    self
      .name("foo:bar")
      .description("The foo:bar command")
      .aliases("afoobar")
  end

  protected def interact(input : ACON::Input::Interface, output : ACON::Output::Interface) : Nil
    output.puts "interact called"
  end

  protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
    @input = input
    @output = output

    output.puts "execute called"

    ACON::Command::Status::SUCCESS
  end
end
