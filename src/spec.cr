module Athena::Console::Spec
  module Tester
    @capture_stderr_separately : Bool = false
    getter! output : ACON::Output::Interface

    def display : String
      self.output.to_s
    end

    def init_output(decorated : Bool? = nil, interactive : Bool? = nil, @capture_stderr_separately : Bool = false) : Nil
      if !@capture_stderr_separately
        @output = ACON::Output::IO.new IO::Memory.new

        decorated.try do |d|
          self.output.decorated = d
        end
      else
      end
    end
  end

  struct ApplicationTester
    include Tester

    getter application : ACON::Application
    getter! input : ACON::Input::Interface
    getter status : ACON::Command::Status? = nil

    def initialize(@application : ACON::Application); end

    def run(input : ACON::Input::HashType, *, decorated : Bool? = nil, interactive : Bool? = nil, capture_stderr_separately : Bool = false) : ACON::Command::Status
      @input = ACON::Input::Hash.new input

      interactive.try do |i|
        self.input.interactive = i
      end

      # TODO: Something about inputs?

      self.init_output(
        decorated: decorated,
        interactive: interactive,
        capture_stderr_separately: capture_stderr_separately
      )

      @status = @application.run self.input, self.output
    end
  end
end
