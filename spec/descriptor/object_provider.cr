module ObjectProvider
  def self.input_arguments : Hash(String, ACON::Input::Argument)
    {
      "input_argument_1"          => ACON::Input::Argument.new("argument_name", :required),
      "input_argument_2"          => ACON::Input::Argument.new("argument_name", :is_array, "argument description"),
      "input_argument_3"          => ACON::Input::Argument.new("argument_name", :optional, "argument description", "default_value"),
      "input_argument_4"          => ACON::Input::Argument.new("argument_name", :required, "multiline\nargument description"),
      "input_argument_with_style" => ACON::Input::Argument.new("argument_name", :optional, "argument description", "<comment>style</>"),
    }
  end

  def self.input_options : Hash(String, ACON::Input::Option)
    {
      "input_option_1"                => ACON::Input::Option.new("option_name", "o", :none),
      "input_option_2"                => ACON::Input::Option.new("option_name", "o", :optional, "option description", "default_value"),
      "input_option_3"                => ACON::Input::Option.new("option_name", "o", :required, "option description"),
      "input_option_4"                => ACON::Input::Option.new("option_name", "o", ACON::Input::Option::Value.flags(IS_ARRAY, OPTIONAL), "option description", Array(String).new),
      "input_option_5"                => ACON::Input::Option.new("option_name", "o", :required, "multiline\noption description"),
      "input_option_6"                => ACON::Input::Option.new("option_name", {"o", "O"}, :required, "option with multiple shortcuts"),
      "input_option_with_style"       => ACON::Input::Option.new("option_name", "o", :required, "option description", "<comment>style</>"),
      "input_option_with_style_array" => ACON::Input::Option.new("option_name", "o", ACON::Input::Option::Value.flags(IS_ARRAY, REQUIRED), "option description", ["<comment>Hello</comment>", "<info>world</info>"]),
    }
  end
end
