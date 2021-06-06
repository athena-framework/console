require "../spec_helper"
require "./object_provider"

abstract struct AbstractDescriptorTestCase < ASPEC::TestCase
  @[DataProvider("input_argument_test_data")]
  def test_describe_input_argument(argument : ACON::Input::Argument, expected : String) : Nil
    self.assert_description expected, argument
  end

  @[DataProvider("input_option_test_data")]
  def test_describe_input_option(argument : ACON::Input::Option, expected : String) : Nil
    self.assert_description expected, argument
  end

  def input_argument_test_data : Array
    self.description_test_data ObjectProvider.input_arguments
  end

  def input_option_test_data : Array
    self.description_test_data ObjectProvider.input_options
  end

  protected abstract def descriptor : ACON::Descriptor::Interface
  protected abstract def format : String

  protected def description_test_data(data : Hash(String, _)) : Array
    data.map do |k, v|
      normalized_path = File.join __DIR__, "..", "fixtures", "text"
      {v, File.read "#{normalized_path}/#{k}.#{self.format}"}
    end
  end

  protected def assert_description(expected : String, object, context : ACON::Descriptor::Context = ACON::Descriptor::Context.new) : Nil
    output = ACON::Output::IO.new IO::Memory.new
    self.descriptor.describe output, object, context.copy_with(raw_output: true)
    output.to_s.strip.should eq expected.strip
  end
end
