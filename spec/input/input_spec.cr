require "../spec_helper"

describe ACON::Input do
  describe "options" do
    it "parses long option" do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"--name" => "foo"},
        ACON::Input::Definition.new(ACON::Input::Option.new("name"))
      )

      input.option("name").should eq "foo"

      input.set_option "name", "bar"
      input.option("name").should eq "bar"
      input.options.should eq({"name" => "bar"})
    end

    it "parses short option" do
      input = ACON::Input::Hash.new(
        ACON::Input::HashType{"-n" => "foo"},
        ACON::Input::Definition.new(ACON::Input::Option.new("name", shortcut: "n"))
      )

      input.option("name").should eq "foo"

      input.set_option "name", "bar"
      input.option("name").should eq "bar"
      input.options.should eq({"name" => "bar"})
    end

    it "uses default when not provided" do
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

    it "should parse explicit empty string value" do
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

    it "should parse explicit nil value" do
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

    describe "negatable option" do
      it "non negated" do
        input = ACON::Input::Hash.new(
          ACON::Input::HashType{"--name" => nil},
          ACON::Input::Definition.new(
            ACON::Input::Option.new("name", value_mode: :negatable)
          )
        )

        input.has_option?("name").should be_true
        input.has_option?("no-name").should be_true
        input.option("name").should be_true
        input.option("no-name").should be_false
      end

      it "negated" do
        input = ACON::Input::Hash.new(
          ACON::Input::HashType{"--no-name" => nil},
          ACON::Input::Definition.new(
            ACON::Input::Option.new("name", value_mode: :negatable)
          )
        )

        input.option("name").should be_false
        input.option("no-name").should be_true
      end

      it "with default" do
        input = ACON::Input::Hash.new(
          ACON::Input::HashType.new,
          ACON::Input::Definition.new(
            ACON::Input::Option.new("name", value_mode: :negatable, default: nil)
          )
        )

        input.option("name").should be_nil
        input.option("no-name").should be_nil
      end
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
      typeof(input.argument("bar")).should eq String?
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

    describe "#argument(T)" do
      it "optional arg without default raises when accessed via non nilable type" do
        input = ACON::Input::Hash.new(
          ACON::Input::HashType{"name" => "foo"},
          ACON::Input::Definition.new(
            ACON::Input::Argument.new("name"),
          )
        )

        expect_raises ACON::Exceptions::Logic, "Cannot cast optional argument 'name' to non-nilable type 'String' without a default." do
          input.argument "name", String
        end
      end

      it "optional arg with default raises when accessed via non nilable type" do
        input = ACON::Input::Hash.new(
          ACON::Input::HashType.new,
          ACON::Input::Definition.new(
            ACON::Input::Argument.new("name", default: "bar"),
          )
        )

        arg = input.argument "name", String
        typeof(arg).should eq String
        arg.should eq "bar"
      end

      it "optional arg without default accessed via nilable type" do
        input = ACON::Input::Hash.new(
          ACON::Input::HashType{"name2" => "foo"},
          ACON::Input::Definition.new(
            ACON::Input::Argument.new("name"),
            ACON::Input::Argument.new("name2"),
          )
        )

        arg = input.argument "name2", String?
        typeof(arg).should eq String?
        arg.should eq "foo"
      end

      it "arg that doesnt exist" do
        input = ACON::Input::Hash.new(
          ACON::Input::HashType{"name" => "foo"},
          ACON::Input::Definition.new(
            ACON::Input::Argument.new("name"),
          )
        )

        expect_raises ACON::Exceptions::InvalidArgument, "The 'foo' argument does not exist." do
          input.argument "foo"
        end
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
