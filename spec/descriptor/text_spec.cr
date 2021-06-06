require "../spec_helper"
require "./abstract_descriptor_test_case"

struct TextDescriptorTest < AbstractDescriptorTestCase
  # TODO: Include test data for double width chars
  # For both Application and Command contexts

  def ptest_describe_application_filtered_namespace : Nil
  end

  protected def descriptor : ACON::Descriptor::Interface
    ACON::Descriptor::Text.new
  end

  protected def format : String
    "txt"
  end
end
