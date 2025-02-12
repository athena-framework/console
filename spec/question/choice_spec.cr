require "../spec_helper"

struct ChoiceQuestionTest < ASPEC::TestCase
  def test_new_empty_choices : Nil
    expect_raises ACON::Exception::Logic, "Choice questions must have at least 1 choice available." do
      ACON::Question::Choice.new "A question", Array(String).new
    end
  end

  def test_custom_validator : Nil
    question = ACON::Question::Choice.new(
      "A question",
      [
        "First response",
        "Second response",
        "Third response",
        "Fourth response",
      ]
    )

    question.validator do
      "FOO"
    end

    {"First response", "First response ", " First response", " First response "}.each do |answer|
      if validator = question.validator
        actual = validator.call answer

        actual.should eq "FOO"
      end
    end
  end

  def test_validator_exact_match : Nil
    question = ACON::Question::Choice.new(
      "A question",
      [
        "First response",
        "Second response",
        "Third response",
        "Fourth response",
      ]
    )

    {"First response", "First response ", " First response", " First response "}.each do |answer|
      if validator = question.validator
        validator.call(answer).should eq "First response"
      end
    end
  end

  def test_validator_index_match : Nil
    question = ACON::Question::Choice.new(
      "A question",
      [
        "First response",
        "Second response",
        "Third response",
        "Fourth response",
      ]
    )

    {"0"}.each do |answer|
      if validator = question.validator
        validator.call(answer).should eq "First response"
      end
    end
  end

  def test_non_trimmable : Nil
    question = ACON::Question::Choice.new(
      "A question",
      [
        "First response ",
        " Second response",
        "  Third response  ",
      ]
    )

    question.trimmable = false

    if validator = question.validator
      validator.not_nil!.call("  Third response  ").should eq "  Third response  "
    end
  end

  @[DataProvider("hash_choice_provider")]
  def test_validator_hash_choices(answer : String, expected : String) : Nil
    question = ACON::Question::Choice.new(
      "A question",
      {
        "0"   => "First choice",
        "foo" => "Foo",
        "99"  => "N°99",
      }
    )

    if validator = question.validator
      validator.call(answer).should eq expected
    end
  end

  def hash_choice_provider : Hash
    {
      "'0' choice by key"            => {"0", "First choice"},
      "'0' choice by value"          => {"First choice", "First choice"},
      "select by key"                => {"foo", "Foo"},
      "select by value"              => {"Foo", "Foo"},
      "select by key, numeric key"   => {"99", "N°99"},
      "select by value, numeric key" => {"N°99", "N°99"},
    }
  end
end
