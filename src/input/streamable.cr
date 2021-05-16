module Athena::Console::Input::Streamable
  include Athena::Console::Input::Interface

  abstract def stream : IO?
  abstract def stream=(@stream : IO?)
end
