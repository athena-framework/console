require "../spec_helper"

describe ACON::Input do
  describe "options" do
    it do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"--name" => "foo"},
        ACON::Input::Definition.new(ACON::Input::Option.new("name"))
      )

      input.option("name").should eq "foo"

      input.set_option "name", "bar"
      input.option("name").should eq "bar"
      input.options.should eq({"name" => "bar"})
    end

    it do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"--name" => "foo"},
        ACON::Input::Definition.new(
          ACON::Input::Option.new("name"),
          ACON::Input::Option.new("bar", nil, :optional, "", "default")
        )
      )

      input.option("bar").should eq "default"
      input.options.should eq({"name" => "foo", "bar" => "default"})
    end

    it do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"--name" => "foo", "--bar" => ""},
        ACON::Input::Definition.new(
          ACON::Input::Option.new("name"),
          ACON::Input::Option.new("bar", nil, :optional, "", "default")
        )
      )

      input.option("bar").should eq ""
      input.options.should eq({"name" => "foo", "bar" => ""})
    end

    it do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"--name" => "foo", "--bar" => nil},
        ACON::Input::Definition.new(
          ACON::Input::Option.new("name"),
          ACON::Input::Option.new("bar", nil, :optional, "", "default")
        )
      )

      input.option("bar").should be_nil
      input.options.should eq({"name" => "foo", "bar" => nil})
    end

    it "set invalid option" do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"--name" => "foo"},
        ACON::Input::Definition.new(
          ACON::Input::Option.new("name"),
          ACON::Input::Option.new("bar", nil, :optional, "", "default")
        )
      )

      expect_raises ACON::Exceptions::InvalidArgument, "The 'foo' option does not exist." do
        input.set_option "foo", "foo"
      end
    end

    it "get invalid option" do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"--name" => "foo"},
        ACON::Input::Definition.new(
          ACON::Input::Option.new("name"),
          ACON::Input::Option.new("bar", nil, :optional, "", "default")
        )
      )

      expect_raises ACON::Exceptions::InvalidArgument, "The 'foo' option does not exist." do
        input.option "foo"
      end
    end
  end

  describe "arguments" do
    it do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"name" => "foo"},
        ACON::Input::Definition.new(
          ACON::Input::Argument.new("name"),
        )
      )

      input.argument("name").should eq "foo"
      input.set_argument "name", "bar"
      input.argument("name").should eq "bar"
      input.arguments.should eq({"name" => "bar"})
    end

    it do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"name" => "foo"},
        ACON::Input::Definition.new(
          ACON::Input::Argument.new("name"),
          ACON::Input::Argument.new("bar", :optional, "", "default")
        )
      )

      input.argument("bar").should eq "default"
      input.arguments.should eq({"name" => "foo", "bar" => "default"})
    end

    it "set invalid option" do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"name" => "foo"},
        ACON::Input::Definition.new(
          ACON::Input::Argument.new("name"),
          ACON::Input::Argument.new("bar", :optional, "", "default")
        )
      )

      expect_raises ACON::Exceptions::InvalidArgument, "The 'foo' argument does not exist." do
        input.set_argument "foo", "foo"
      end
    end

    it "get invalid option" do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"name" => "foo"},
        ACON::Input::Definition.new(
          ACON::Input::Argument.new("name"),
          ACON::Input::Argument.new("bar", :optional, "", "default")
        )
      )

      expect_raises ACON::Exceptions::InvalidArgument, "The 'foo' argument does not exist." do
        input.argument "foo"
      end
    end
  end

  describe "#validate" do
    it "missing arguments" do
      input = ACON::Input::Hash.new
      input.bind ACON::Input::Definition.new ACON::Input::Argument.new("name", :required)

      expect_raises ACON::Exceptions::ValidationFailed, "Not enough arguments (missing: 'name')." do
        input.validate
      end
    end

    it "missing required argument" do
      input = ACON::Input::Hash.new bar: "baz"
      input.bind ACON::Input::Definition.new(
        ACON::Input::Argument.new("name", :required),
        ACON::Input::Argument.new("bar", :optional)
      )

      expect_raises ACON::Exceptions::ValidationFailed, "Not enough arguments (missing: 'name')." do
        input.validate
      end
    end
  end
end
