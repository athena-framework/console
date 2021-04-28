require "../spec_helper"

@[ASPEC::TestCase::Focus]
struct InputDefinitionTest < ASPEC::TestCase
  getter arg_foo : ACON::Input::Argument { ACON::Input::Argument.new "foo" }
  getter arg_foo1 : ACON::Input::Argument { ACON::Input::Argument.new "foo" }
  getter arg_foo2 : ACON::Input::Argument { ACON::Input::Argument.new "foo2", :required }
  getter arg_bar : ACON::Input::Argument { ACON::Input::Argument.new "bar" }

  getter opt_foo : ACON::Input::Option { ACON::Input::Option.new "foo", "f" }
  getter opt_bar : ACON::Input::Option { ACON::Input::Option.new "bar", "b" }

  def test_new_arguments : Nil
    definition = ACON::Input::Definition.new
    definition.arguments.should be_empty

    # Splat
    definition = ACON::Input::Definition.new self.arg_foo, self.arg_bar
    definition.arguments.should eq({"foo" => self.arg_foo, "bar" => self.arg_bar})

    # Array
    definition = ACON::Input::Definition.new [self.arg_foo, self.arg_bar]
    definition.arguments.should eq({"foo" => self.arg_foo, "bar" => self.arg_bar})

    # Hash
    definition = ACON::Input::Definition.new({"foo" => self.arg_foo, "bar" => self.arg_bar})
    definition.arguments.should eq({"foo" => self.arg_foo, "bar" => self.arg_bar})
  end

  def test_new_options : Nil
    definition = ACON::Input::Definition.new
    definition.options.should be_empty

    # Splat
    definition = ACON::Input::Definition.new self.opt_foo, self.opt_bar
    definition.options.should eq({"foo" => self.opt_foo, "bar" => self.opt_bar})

    # Array
    definition = ACON::Input::Definition.new [self.opt_foo, self.opt_bar]
    definition.options.should eq({"foo" => self.opt_foo, "bar" => self.opt_bar})

    # Hash
    definition = ACON::Input::Definition.new({"foo" => self.opt_foo, "bar" => self.opt_bar})
    definition.options.should eq({"foo" => self.opt_foo, "bar" => self.opt_bar})
  end

  def test_set_arguments : Nil
    definition = ACON::Input::Definition.new

    definition.arguments = [self.arg_foo]
    definition.arguments.should eq({"foo" => self.arg_foo})

    definition.arguments = [self.arg_bar]
    definition.arguments.should eq({"bar" => self.arg_bar})
  end

  def test_add_arguments : Nil
    definition = ACON::Input::Definition.new

    definition << [self.arg_foo]
    definition.arguments.should eq({"foo" => self.arg_foo})

    definition << [self.arg_bar]
    definition.arguments.should eq({"foo" => self.arg_foo, "bar" => self.arg_bar})
  end

  def test_add_argument : Nil
    definition = ACON::Input::Definition.new

    definition << self.arg_foo
    definition.arguments.should eq({"foo" => self.arg_foo})

    definition << self.arg_bar
    definition.arguments.should eq({"foo" => self.arg_foo, "bar" => self.arg_bar})
  end

  def test_add_argument_must_have_unique_names : Nil
    definition = ACON::Input::Definition.new
    definition << self.arg_foo

    expect_raises ACON::Exceptions::Logic, "An argument with the name 'foo' already exists." do
      definition << self.arg_foo
    end
  end

  def test_add_argument_array_argument_must_be_last : Nil
    definition = ACON::Input::Definition.new
    definition << ACON::Input::Argument.new "foo_array", :is_array

    expect_raises ACON::Exceptions::Logic, "Cannot add a required argument 'foo' after Array argument 'foo_array'." do
      definition << ACON::Input::Argument.new "foo"
    end
  end

  def test_add_argument_required_argument_cannot_follow_optional : Nil
    definition = ACON::Input::Definition.new
    definition << self.arg_foo

    expect_raises ACON::Exceptions::Logic, "Cannot add required argument 'foo2' after the optional argument 'foo'." do
      definition << self.arg_foo2
    end
  end

  def test_argument : Nil
    definition = ACON::Input::Definition.new
    definition << self.arg_foo

    self.arg_foo.should be definition.argument "foo"
    self.arg_foo.should be definition.argument 0
  end

  def test_argument_missing : Nil
    definition = ACON::Input::Definition.new
    definition << self.arg_foo

    expect_raises ACON::Exceptions::InvalidArgument, "The argument 'bar' does not exist." do
      definition.argument "bar"
    end
  end

  def test_has_argument : Nil
    definition = ACON::Input::Definition.new
    definition << self.arg_foo

    definition.has_argument?("foo").should be_true
    definition.has_argument?(0).should be_true
    definition.has_argument?("bar").should be_false
    definition.has_argument?(1).should be_false
  end

  def test_required_argument_count : Nil
    definition = ACON::Input::Definition.new

    definition << self.arg_foo2
    definition.required_argument_count.should eq 1

    definition << self.arg_foo
    definition.required_argument_count.should eq 1
  end

  def test_argument_count : Nil
    definition = ACON::Input::Definition.new

    definition << self.arg_foo2
    definition.argument_count.should eq 1

    definition << self.arg_foo
    definition.argument_count.should eq 2

    definition << ACON::Input::Argument.new "foo_array", :is_array
    definition.argument_count.should eq Int32::MAX
  end

  def test_argument_defaults : Nil
    definition = ACON::Input::Definition.new(
      ACON::Input::Argument.new("foo1", :optional),
      ACON::Input::Argument.new("foo2", :optional, "", "default"),
      ACON::Input::Argument.new("foo3", ACON::Input::Argument::Mode::OPTIONAL | ACON::Input::Argument::Mode::IS_ARRAY),
    )

    {"foo1" => nil, "foo2" => "default", "foo3" => [] of String}.should eq definition.argument_defaults

    definition = ACON::Input::Definition.new(
      ACON::Input::Argument.new("foo4", ACON::Input::Argument::Mode::OPTIONAL | ACON::Input::Argument::Mode::IS_ARRAY, default: ["1", "2"]),
    )

    {"foo4" => ["1", "2"]}.should eq definition.argument_defaults
  end
end
