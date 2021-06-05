module Athena::Console::Style::Interface
  abstract def ask(question : String, default : _)
  abstract def ask_hidden(question : String)
  abstract def caution(messages : String | Enumerable(String)) : Nil
  abstract def comment(messages : String | Enumerable(String)) : Nil
  abstract def confirm(question : String, default : Bool = true) : Bool
  abstract def error(messages : String | Enumerable(String)) : Nil
  abstract def choice(question : String, choices : Enumerable, default = nil)
  abstract def info(messages : String | Enumerable(String)) : Nil
  abstract def listing(elements : Enumerable) : Nil
  abstract def new_line(count : Int32 = 1) : Nil
  abstract def note(messages : String | Enumerable(String)) : Nil
  abstract def section(message : String) : Nil
  abstract def success(messages : String | Enumerable(String)) : Nil
  abstract def text(messages : String | Enumerable(String)) : Nil
  abstract def title(message : String) : Nil
  # abstract def table(headers : Enumerable, rows : Enumerable(Enumerable)) : Nil
  # abstract def progress_start(max : Int32 = 0) : Nil
  # abstract def progress_advance(step : Int32 = 1) : Nil
  # abstract def progress_finish : Nil
  abstract def warning(messages : String | Enumerable(String)) : Nil
end
