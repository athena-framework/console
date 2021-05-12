module Athena::Console::Input::Streamable
  abstract def stream : IO?
  abstract def stream=(@stream : IO?)
end
