abstract struct Athena::Console::Descriptor::Context
  getter format : String
  getter? raw_text : Bool
  getter? raw_output : Bool? = nil

  def initialize(@format : String = "txt", @raw_text : Bool = false, @raw_output : Bool? = nil)
  end
end
