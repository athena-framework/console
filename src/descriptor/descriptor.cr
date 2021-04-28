require "./interface"

abstract class Athena::Console::Descriptor
  include Athena::Console::Descriptor::Interface

  abstract def describe(output : ACON::Output::Interface, object : ACON::Application, context : ACON::Descriptor::ListContext) : Nil

  protected def write(output : ACON::Output::Interface, content : String, decorated : Bool = false) : Nil
    output.print content, output_type: decorated ? Athena::Console::Output::Type::NORMAL : Athena::Console::Output::Type::RAW
  end
end
