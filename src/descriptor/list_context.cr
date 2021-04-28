struct Athena::Console::Descriptor::ListContext < Athena::Console::Descriptor::Context
  getter? short : Bool
  getter namespace : String?

  def initialize(@namespace : String? = nil, @short : Bool = false, format : String = "txt", raw_text : Bool = false)
    super format, raw_text
  end
end
