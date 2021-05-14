module Athena::Console::Style::Interface
  abstract def ask(question : String, default : _)
  abstract def ask_hidden(question : String)
  abstract def caution(message : String) : Nil
  abstract def comment(message : String) : Nil
  abstract def confirm(question : String, default : Bool = true) : Bool
  abstract def error(message : String) : Nil
  # # abstract def choice(question : String, choices : Enumerable(String), default = nil)
  abstract def info(message : String) : Nil
  # abstract def listing(elements : Array) : Nil
  abstract def new_line(count : Int32 = 1) : Nil
  abstract def note(message : String) : Nil
  abstract def section(message : String) : Nil
  abstract def success(message : String) : Nil
  abstract def text(message : String) : Nil
  abstract def title(message : String) : Nil
  # abstract def table(headers : Enumerable(String), rows : Enumerable(Enumerable(String))) : Nil
  # abstract def progress_start(max : Int32 = 0) : Nil
  # abstract def progress_advance(step : Int32 = 1) : Nil
  # abstract def progress_finish : Nil
  abstract def warning(message : String) : Nil
end
