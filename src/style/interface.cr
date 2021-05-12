module Athena::Console::Style::Interface
  abstract def confirm(question : String, default : Bool = true) : Bool
  abstract def new_line(count : Int32 = 1) : Nil
end
