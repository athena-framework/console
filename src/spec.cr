module Athena::Console::Spec
  module Tester
    @capture_stderr_separately : Bool = false
    getter! output : ACON::Output::Interface

    def display : String
      self.output.to_s
    end

    def error_output : String
      raise ACON::Exceptions::Logic.new "The error output is not available when the test is ran without 'capture_stderr_separately' set." unless @capture_stderr_separately

      self.output.as(ACON::Output::ConsoleOutput).error_output.to_s
    end

    def init_output(
      decorated : Bool? = nil,
      interactive : Bool? = nil,
      verbosity : ACON::Output::Verbosity? = nil,
      @capture_stderr_separately : Bool = false
    ) : Nil
      if !@capture_stderr_separately
        @output = ACON::Output::IO.new IO::Memory.new

        decorated.try do |d|
          self.output.decorated = d
        end

        verbosity.try do |v|
          self.output.verbosity = v
        end
      else
        @output = ACON::Output::ConsoleOutput.new(
          verbosity || ACON::Output::Verbosity::NORMAL,
          decorated
        )

        error_output = ACON::Output::IO.new IO::Memory.new
        error_output.formatter = self.output.formatter
        error_output.verbosity = self.output.verbosity
        error_output.decorated = self.output.decorated?

        self.output.as(ACON::Output::ConsoleOutput).stderr = error_output
        self.output.as(ACON::Output::IO).io = IO::Memory.new
      end
    end
  end

  struct ApplicationTester
    include Tester

    getter application : ACON::Application
    getter! input : ACON::Input::Interface
    getter status : ACON::Command::Status? = nil

    def initialize(@application : ACON::Application); end

    def run(input : ACON::Input::HashType = ACON::Input::HashType.new, *, decorated : Bool? = nil, interactive : Bool? = nil, capture_stderr_separately : Bool = false, verbosity : ACON::Output::Verbosity? = nil) : ACON::Command::Status
      @input = ACON::Input::Hash.new input

      interactive.try do |i|
        self.input.interactive = i
      end

      # TODO: Something about inputs?

      self.init_output(
        decorated: decorated,
        interactive: interactive,
        capture_stderr_separately: capture_stderr_separately,
        verbosity: verbosity
      )

      @status = @application.run self.input, self.output
    end
  end

  class MockCommand < Athena::Console::Command
    def initialize(name : String, &@callback : Proc(ACON::Input::Interface, ACON::Output::Interface, ACON::Command::Status))
      super name
    end

    protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
      @callback.call input, output
    end
  end
end
