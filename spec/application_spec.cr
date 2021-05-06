require "./spec_helper"

private RENDER_EXCEPTION1 = <<-OUTPUT

                                 
  Command 'foo' is not defined.  
                                 


OUTPUT

private RENDER_EXCEPTION2 = <<-OUTPUT

                                      
  The '--foo' option does not exist.  
                                      

list [--raw] [--format FORMAT] [--short] [--] [<namespace>]


OUTPUT

@[ASPEC::TestCase::Focus]
struct ApplicationTest < ASPEC::TestCase
  @col_size : Int32?

  def initialize
    @col_size = ENV["COLUMNS"]?.try &.to_i
  end

  def tear_down : Nil
    if size = @col_size
      ENV["COLUMNS"] = size.to_s
    else
      ENV.delete "COLUMNS"
    end

    ENV.delete "SHELL_VERBOSITY"
  end

  def test_long_version : Nil
    ACON::Application.new("foo", "1.2.3").long_version.should eq "foo <info>1.2.3</info>"
  end

  def test_help : Nil
    ACON::Application.new("foo", "1.2.3").help.should eq "foo <info>1.2.3</info>"
  end

  def test_commands : Nil
    app = ACON::Application.new "foo"
    commands = app.commands

    commands["help"].should be_a ACON::Commands::Help
    commands["list"].should be_a ACON::Commands::List

    app.add FooCommand.new
    commands = app.commands "foo"
    commands.size.should eq 1
  end

  def test_commands_with_loader : Nil
    app = ACON::Application.new "foo"
    commands = app.commands

    commands["help"].should be_a ACON::Commands::Help
    commands["list"].should be_a ACON::Commands::List

    app.add FooCommand.new
    commands = app.commands "foo"
    commands.size.should eq 1

    app.command_loader = ACON::Loader::Factory.new({
      "foo:bar1" => ->{ Foo1Command.new.as ACON::Command },
    })
    commands = app.commands "foo"
    commands.size.should eq 2
    commands["foo:bar"].should be_a FooCommand
    commands["foo:bar1"].should be_a Foo1Command
  end

  def test_add : Nil
    app = ACON::Application.new "foo"
    app.add foo = FooCommand.new
    commands = app.commands

    commands["foo:bar"].should be foo

    # TODO: Add a splat/enumerable overload of #add ?
  end

  def test_has_get : Nil
    app = ACON::Application.new "foo"
    app.has?("list").should be_true
    app.has?("afoobar").should be_false

    app.add foo = FooCommand.new
    app.has?("afoobar").should be_true
    app.get("afoobar").should be foo
    app.get("foo:bar").should be foo

    app = ACON::Application.new "foo"
    app.add foo = FooCommand.new

    pointerof(app.@wants_help).value = true

    app.get("foo:bar").should be_a ACON::Commands::Help
  end

  def test_has_get_with_loader : Nil
    app = ACON::Application.new "foo"
    app.has?("list").should be_true
    app.has?("afoobar").should be_false

    app.add foo = FooCommand.new
    app.has?("afoobar").should be_true
    app.get("foo:bar").should be foo
    app.get("afoobar").should be foo

    app.command_loader = ACON::Loader::Factory.new({
      "foo:bar1" => ->{ Foo1Command.new.as ACON::Command },
    })

    app.has?("afoobar").should be_true
    app.get("foo:bar").should be foo
    app.get("afoobar").should be foo
    app.has?("foo:bar1").should be_true
    (foo1 = app.get("foo:bar1")).should be_a Foo1Command
    app.has?("afoobar1").should be_true
    app.get("afoobar1").should be foo1
  end

  def test_silent_help : Nil
    app = ACON::Application.new "foo"
    app.auto_exit = false
    app.catch_exceptions = false

    tester = ACON::Spec::ApplicationTester.new app

    tester.run(ACON::Input::HashType{"-h" => true, "-q" => true}, decorated: false)
    tester.display.should be_empty
  end

  def test_get_missing_command : Nil
    app = ACON::Application.new "foo"

    expect_raises ACON::Exceptions::CommandNotFound, "The command 'foofoo' does not exist." do
      app.get "foofoo"
    end
  end

  def test_namespaces : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add Foo1Command.new
    app.namespaces.should eq ["foo"]
  end

  def test_find_namespace : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.find_namespace("foo").should eq "foo"
    app.find_namespace("f").should eq "foo"
    app.add Foo1Command.new
    app.find_namespace("foo").should eq "foo"
  end

  def test_find_namespace_subnamespaces : Nil
    app = ACON::Application.new "foo"
    app.add FooSubnamespaced1Command.new
    app.add FooSubnamespaced2Command.new
    app.find_namespace("foo").should eq "foo"
  end

  def test_find_namespace_ambigous : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add BarBucCommand.new
    app.add Foo2Command.new

    expect_raises ACON::Exceptions::NamespaceNotFound, "The namespace 'f' is ambiguous." do
      app.find_namespace "f"
    end
  end

  def test_find_namespace_invalid : Nil
    app = ACON::Application.new "foo"

    expect_raises ACON::Exceptions::NamespaceNotFound, "There are no commands defined in the 'bar' namespace." do
      app.find_namespace "bar"
    end
  end

  def test_find_namespace_does_not_fail_on_deep_similar_namespaces : Nil
    app = ACON::Application.new "foo"

    command1 = ACON::Spec::MockCommand.new "foo:sublong:bar" do
      ACON::Command::Status::SUCCESS
    end

    command2 = ACON::Spec::MockCommand.new "bar:sub:foo" do
      ACON::Command::Status::SUCCESS
    end

    app.add command1
    app.add command2

    app.find_namespace("f:sub").should eq "foo:sublong"
  end

  def test_find : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new

    app.find("foo:bar").should be_a FooCommand
    app.find("h").should be_a ACON::Commands::Help
    app.find("f:bar").should be_a FooCommand
    app.find("f:b").should be_a FooCommand
    app.find("a").should be_a FooCommand
  end

  def test_find_non_ambiguous : Nil
    app = ACON::Application.new "foo"
    app.add TestAmbiguousCommandRegistering.new
    app.add TestAmbiguousCommandRegistering2.new

    app.find("test").name.should eq "test-ambiguous"
  end

  def test_find_unique_name_but_namespace_name : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add Foo1Command.new
    app.add Foo2Command.new

    expect_raises ACON::Exceptions::CommandNotFound, "Command 'foo1' is not defined." do
      app.find "foo1"
    end
  end

  def test_find_case_sensitive_first : Nil
    app = ACON::Application.new "foo"
    app.add FooSameCaseUppercaseCommand.new
    app.add FooSameCaseLowercaseCommand.new

    app.find("f:B").should be_a FooSameCaseUppercaseCommand
    app.find("f:BAR").should be_a FooSameCaseUppercaseCommand
    app.find("f:b").should be_a FooSameCaseLowercaseCommand
    app.find("f:bar").should be_a FooSameCaseLowercaseCommand
  end

  def test_find_case_insensitive_fallback : Nil
    app = ACON::Application.new "foo"
    app.add FooSameCaseLowercaseCommand.new

    app.find("f:b").should be_a FooSameCaseLowercaseCommand
    app.find("f:B").should be_a FooSameCaseLowercaseCommand
    app.find("foO:BaR").should be_a FooSameCaseLowercaseCommand
  end

  def test_find_case_insensitive_ambiguous : Nil
    app = ACON::Application.new "foo"
    app.add FooSameCaseUppercaseCommand.new
    app.add FooSameCaseLowercaseCommand.new

    expect_raises ACON::Exceptions::CommandNotFound, "Command 'FoO:BaR' is ambiguous." do
      app.find "FoO:BaR"
    end
  end

  def test_find_command_loader : Nil
    app = ACON::Application.new "foo"

    app.command_loader = ACON::Loader::Factory.new({
      "foo:bar" => ->{ FooCommand.new.as ACON::Command },
    })

    app.find("foo:bar").should be_a FooCommand
    app.find("h").should be_a ACON::Commands::Help
    app.find("f:bar").should be_a FooCommand
    app.find("f:b").should be_a FooCommand
    app.find("a").should be_a FooCommand
  end

  @[DataProvider("ambiguous_abbreviations_provider")]
  def test_find_ambiguous_abbreviations(abbreviation, expected_message) : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add Foo1Command.new
    app.add Foo2Command.new

    expect_raises ACON::Exceptions::CommandNotFound, expected_message do
      app.find abbreviation
    end
  end

  def ambiguous_abbreviations_provider : Tuple
    {
      {"f", "Command 'f' is not defined."},
      {"a", "Command 'a' is ambiguous."},
      {"foo:b", "Command 'foo:b' is ambiguous."},
    }
  end

  def test_find_ambiguous_abbreviations_finds_command_if_alternatives_are_hidden : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add FooHiddenCommand.new

    app.find("foo:").should be_a FooCommand
  end

  def test_find_command_equal_namespace
    app = ACON::Application.new "foo"
    app.add Foo3Command.new
    app.add Foo4Command.new

    app.find("foo3:bar").should be_a Foo3Command
    app.find("foo3:bar:toh").should be_a Foo4Command
  end

  def test_find_ambiguous_namespace_but_unique_name
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add FooBarCommand.new

    app.find("f:f").should be_a FooBarCommand
  end

  def test_find_missing_namespace
    app = ACON::Application.new "foo"
    app.add Foo4Command.new

    app.find("f::t").should be_a Foo4Command
  end

  @[DataProvider("invalid_command_names_single_provider")]
  def test_find_alternative_exception_message_single(name) : Nil
    app = ACON::Application.new "foo"
    app.add Foo3Command.new

    expect_raises ACON::Exceptions::CommandNotFound, "Did you mean this?" do
      app.find name
    end
  end

  def invalid_command_names_single_provider : Tuple
    {
      {"foo3:barr"},
      {"fooo3:bar"},
    }
  end

  def test_doesnt_run_alternative_namespace_name : Nil
    app = ACON::Application.new "foo"
    app.add Foo1Command.new
    app.auto_exit = false

    tester = ACON::Spec::ApplicationTester.new app
    tester.run(ACON::Input::HashType{"command" => "foos:bar1"}, decorated: false)
    tester.display.should eq(
      <<-OUTPUT

                                                                
        There are no commands defined in the 'foos' namespace.  
                                                                
        Did you mean this?                                      
            foo                                                 
                                                                


      OUTPUT
    )
  end

  def ptest_run_alternate_command_name : Nil
  end

  def ptest_dont_run_alternate_command_name : Nil
  end

  def test_find_alternative_exception_message_multiple : Nil
    ENV["COLUMNS"] = "120"
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add Foo1Command.new
    app.add Foo2Command.new

    # Command + plural
    ex = expect_raises ACON::Exceptions::CommandNotFound do
      app.find "foo:baR"
    end

    message = ex.message.should_not be_nil
    message.should contain "Did you mean one of these?"
    message.should contain "foo1:bar"
    message.should contain "foo:bar"

    # Namespace + plural
    ex = expect_raises ACON::Exceptions::CommandNotFound do
      app.find "foo2:bar"
    end

    message = ex.message.should_not be_nil
    message.should contain "Did you mean one of these?"
    message.should contain "foo1"

    app.add Foo3Command.new
    app.add Foo4Command.new

    # Subnamespace + plural
    ex = expect_raises ACON::Exceptions::CommandNotFound do
      app.find "foo3:"
    end

    message = ex.message.should_not be_nil
    message.should contain "foo3:bar"
    message.should contain "foo3:bar:toh"
  end

  def test_find_alternative_commands : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add Foo1Command.new
    app.add Foo2Command.new

    ex = expect_raises ACON::Exceptions::CommandNotFound do
      app.find "Unknown command"
    end

    ex.alternatives.should be_empty
    ex.message.should eq "Command 'Unknown command' is not defined."

    # Test if "bar1" command throw a "CommandNotFoundException" and does not contain
    # "foo:bar" as alternative because "bar1" is too far from "foo:bar"
    ex = expect_raises ACON::Exceptions::CommandNotFound do
      app.find "bar1"
    end

    ex.alternatives.should eq ["afoobar1", "foo:bar1"]

    message = ex.message.should_not be_nil
    message.should contain "Command 'bar1' is not defined"
    message.should contain "afoobar1"
    message.should contain "foo:bar1"
    message.should_not match /foo:bar(?!1)/
  end

  def test_find_alternative_commands_with_alias : Nil
    foo_command = FooCommand.new
    foo_command.aliases = ["foo2"]

    app = ACON::Application.new "foo"
    app.command_loader = ACON::Loader::Factory.new({
      "foo3" => ->{ foo_command.as ACON::Command },
    })
    app.add foo_command

    app.find("foo").should be foo_command
  end

  def test_find_alternate_namespace : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add Foo1Command.new
    app.add Foo2Command.new
    app.add Foo3Command.new

    ex = expect_raises ACON::Exceptions::CommandNotFound, "There are no commands defined in the 'Unknown-namespace' namespace." do
      app.find "Unknown-namespace:Unknown-command"
    end
    ex.alternatives.should be_empty

    ex = expect_raises ACON::Exceptions::CommandNotFound do
      app.find "foo2:command"
    end
    ex.alternatives.should eq ["foo", "foo1", "foo3"]

    message = ex.message.should_not be_nil
    message.should contain "There are no commands defined in the 'foo2' namespace."
    message.should contain "foo"
    message.should contain "foo1"
    message.should contain "foo3"
  end

  def test_find_alternates_output : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add Foo1Command.new
    app.add Foo2Command.new
    app.add Foo3Command.new
    app.add FooHiddenCommand.new

    expect_raises ACON::Exceptions::CommandNotFound, "There are no commands defined in the 'Unknown-namespace' namespace." do
      app.find "Unknown-namespace:Unknown-command"
    end.alternatives.should be_empty

    expect_raises ACON::Exceptions::CommandNotFound, /Command 'foo' is not defined\..*Did you mean one of these\?.*/m do
      app.find "foo"
    end.alternatives.should eq ["afoobar", "afoobar1", "afoobar2", "foo1:bar", "foo3:bar", "foo:bar", "foo:bar1"]
  end

  def test_find_double_colon_doesnt_find_command : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add Foo4Command.new

    expect_raises ACON::Exceptions::CommandNotFound, "Command 'foo::bar' is not defined." do
      app.find "foo::bar"
    end
  end

  def test_find_hidden_command_exact_name : Nil
    app = ACON::Application.new "foo"
    app.add FooHiddenCommand.new

    app.find("foo:hidden").should be_a FooHiddenCommand
    app.find("afoohidden").should be_a FooHiddenCommand
  end

  def test_find_ambiguous_commands_if_all_alternatives_are_hidden : Nil
    app = ACON::Application.new "foo"
    app.add FooCommand.new
    app.add FooHiddenCommand.new

    app.find("foo:").should be_a FooCommand
  end

  def test_set_catch_exceptions : Nil
    app = ACON::Application.new "foo"
    app.auto_exit = false
    ENV["COLUMNS"] = "120"
    tester = ACON::Spec::ApplicationTester.new app

    app.catch_exceptions = true
    tester.run(ACON::Input::HashType{"command" => "foo"}, decorated: false)
    tester.display.should eq RENDER_EXCEPTION1

    tester.run(ACON::Input::HashType{"command" => "foo"}, decorated: false, capture_stderr_separately: true)
    tester.error_output.should eq RENDER_EXCEPTION1
    tester.display.should be_empty

    app.catch_exceptions = false

    expect_raises Exception, "Command 'foo' is not defined." do
      tester.run(ACON::Input::HashType{"command" => "foo"}, decorated: false)
    end
  end

  def test_render_exception : Nil
    app = ACON::Application.new "foo"
    app.auto_exit = false
    ENV["COLUMNS"] = "120"
    tester = ACON::Spec::ApplicationTester.new app

    tester.run(ACON::Input::HashType{"command" => "foo"}, decorated: false, capture_stderr_separately: true)
    tester.error_output.should eq RENDER_EXCEPTION1

    tester.run(ACON::Input::HashType{"command" => "foo"}, decorated: false, capture_stderr_separately: true, verbosity: :verbose)
    tester.error_output.should contain "Exception trace"

    tester.run(ACON::Input::HashType{"command" => "list", "--foo" => true}, decorated: false, capture_stderr_separately: true)
    tester.error_output.should eq RENDER_EXCEPTION2
  end
end
