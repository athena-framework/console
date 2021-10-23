module Athena::Console::Spec
  module Tester
    @capture_stderr_separately : Bool = false
    getter! output : ACON::Output::Interface
    setter inputs : Array(String) = [] of String

    def display : String
      raise ACON::Exceptions::Logic.new "Output not initialized.  Did you execute the command before requesting the display?" unless (output = @output)
      output.to_s
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

    private def create_input_stream(inputs : Array(String)) : IO
      input_stream = IO::Memory.new

      inputs.each do |input|
        input_stream << "#{input}\n"
      end

      input_stream.rewind

      input_stream
    end
  end

  struct ApplicationTester
    include Tester

    getter application : ACON::Application
    getter! input : ACON::Input::Interface
    getter status : ACON::Command::Status? = nil

    def initialize(@application : ACON::Application); end

    def run(
      decorated : Bool = false,
      interactive : Bool? = nil,
      capture_stderr_separately : Bool = false,
      verbosity : ACON::Output::Verbosity? = nil,
      **args : _
    )
      self.run args.to_h.transform_keys(&.to_s), decorated: decorated, interactive: interactive, capture_stderr_separately: capture_stderr_separately, verbosity: verbosity
    end

    def run(
      input : Hash(String, _) = Hash(String, String).new,
      *,
      decorated : Bool? = nil,
      interactive : Bool? = nil,
      capture_stderr_separately : Bool = false,
      verbosity : ACON::Output::Verbosity? = nil
    ) : ACON::Command::Status
      @input = ACON::Input::Hash.new input

      interactive.try do |i|
        self.input.interactive = i
      end

      unless (inputs = @inputs).empty?
        self.input.stream = self.create_input_stream inputs
      end

      self.init_output(
        decorated: decorated,
        interactive: interactive,
        capture_stderr_separately: capture_stderr_separately,
        verbosity: verbosity
      )

      @status = @application.run self.input, self.output
    end
  end

  struct CommandTester
    include Tester

    getter! input : ACON::Input::Interface
    getter status : ACON::Command::Status? = nil

    def initialize(@command : ACON::Command); end

    def execute(
      decorated : Bool = false,
      interactive : Bool? = nil,
      capture_stderr_separately : Bool = false,
      verbosity : ACON::Output::Verbosity? = nil,
      **args : _
    )
      self.execute args.to_h.transform_keys(&.to_s), decorated: decorated, interactive: interactive, capture_stderr_separately: capture_stderr_separately, verbosity: verbosity
    end

    def execute(
      input : Hash(String, _) = Hash(String, String).new,
      *,
      decorated : Bool = false,
      interactive : Bool? = nil,
      capture_stderr_separately : Bool = false,
      verbosity : ACON::Output::Verbosity? = nil
    ) : ACON::Command::Status
      if !input.has_key?("command") && (application = @command.application?) && application.definition.has_argument?("command")
        input.merge({"command" => @command.name})
      end

      @input = ACON::Input::Hash.new input
      self.input.stream = self.create_input_stream @inputs

      interactive.try do |i|
        self.input.interactive = i
      end

      self.init_output(
        decorated: decorated,
        interactive: interactive,
        capture_stderr_separately: capture_stderr_separately,
        verbosity: verbosity
      )

      @status = @command.run self.input, self.output
    end
  end
end
