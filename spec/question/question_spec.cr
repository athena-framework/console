require "../spec_helper"

@[ASPEC::TestCase::Focus]
struct QuestionTest < ASPEC::TestCase
  @question : ACON::Question(Nil)

  def initialize
    @question = ACON::Question(Nil).new "Test Question", nil
  end

  def test_default : Nil
    @question.default.should be_nil
    ACON::Question(String).new("Test Question", "FOO").default.should eq "FOO"
  end

  def test_hidden_autocompleter_callback : Nil
    @question.autocompleter_callback do |string|
      [] of String
    end

    expect_raises ACON::Exceptions::Logic, "A hidden question cannot use the autocompleter" do
      @question.hidden = true
    end
  end
end
