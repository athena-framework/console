require "./spec_helper"

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

  def ptest_find_namespace_non_ambiguous : Nil
  end
end
