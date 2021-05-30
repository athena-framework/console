require "../spec_helper"
require "./abstract_question_helper_testcase"

struct QuestionHelperTest < AbstractQuestionHelperTest
  @helper : ACON::Helper::Question

  def initialize
    @helper = ACON::Helper::Question.new

    super
  end

  def test_ask_choice_question : Nil
    heros = ["Superman", "Batman", "Spiderman"]
    self.with_input "\n1\n  1  \nGeorge\n1\nGeorge\n\n\n" do |input|
      question = ACON::Question::Choice.new "Who is your favorite superhero?", heros, 2
      question.max_attempts = 1

      # First answer is empty, so should use default
      @helper.ask(input, @output, question).should eq "Spiderman"

      question = ACON::Question::Choice.new "Who is your favorite superhero?", heros
      question.max_attempts = 1

      @helper.ask(input, @output, question).should eq "Batman"
      @helper.ask(input, @output, question).should eq "Batman"

      question = ACON::Question::Choice.new "Who is your favorite superhero?", heros
      question.error_message = "Input '%s' is not a superhero!"
      question.max_attempts = 2

      @helper.ask(input, @output, question).should eq "Batman"

      begin
        question = ACON::Question::Choice.new "Who is your favorite superhero?", heros, 1
        question.max_attempts = 1
        @helper.ask input, @output, question
      rescue ex : ACON::Exceptions::InvalidArgument
        ex.message.should eq "Value 'George' is invalid."
      end

      question = ACON::Question::Choice.new "Who is your favorite superhero?", heros, "0"
      question.max_attempts = 1

      @helper.ask(input, @output, question).should eq "Superman"
    end
  end

  def test_ask_choice_question_non_interactive : Nil
    heros = ["Superman", "Batman", "Spiderman"]
    self.with_input "\n1\n  1  \nGeorge\n1\nGeorge\n1\n", false do |input|
      question = ACON::Question::Choice.new "Who is your favorite superhero?", heros, 0
      @helper.ask(input, @output, question).should eq "Superman"

      question = ACON::Question::Choice.new "Who is your favorite superhero?", heros, "Batman"
      @helper.ask(input, @output, question).should eq "Batman"

      question = ACON::Question::Choice.new "Who is your favorite superhero?", heros
      @helper.ask(input, @output, question).should be_nil

      question = ACON::Question::Choice.new "Who is your favorite superhero?", heros, 0
      question.validator = nil
      @helper.ask(input, @output, question).should eq "Superman"

      begin
        question = ACON::Question::Choice.new "Who is your favorite superhero?", heros
        @helper.ask input, @output, question
      rescue ex : ACON::Exceptions::InvalidArgument
        ex.message.should eq "Value '' is invalid."
      end
    end
  end

  def test_ask_multiple_choice : Nil
    heros = ["Superman", "Batman", "Spiderman"]

    self.with_input "1\n0,2\n 0 , 2  " do |input|
      question = ACON::Question::MultipleChoice.new "Who are your favorite superheros?", heros
      question.max_attempts = 1

      @helper.ask(input, @output, question).should eq ["Batman"]
      @helper.ask(input, @output, question).should eq ["Superman", "Spiderman"]
      @helper.ask(input, @output, question).should eq ["Superman", "Spiderman"]

      question = ACON::Question::MultipleChoice.new "Who are your favorite superheros?", heros, "0,1"
      question.max_attempts = 1

      @helper.ask(input, @output, question).should eq ["Superman", "Batman"]

      question = ACON::Question::MultipleChoice.new "Who are your favorite superheros?", heros, " 0 , 1 "
      question.max_attempts = 1

      @helper.ask(input, @output, question).should eq ["Superman", "Batman"]
    end
  end

  def test_ask_multiple_choice_non_interactive : Nil
    heros = ["Superman", "Batman", "Spiderman"]

    self.with_input "1\n0,2\n 0 , 2  ", false do |input|
      question = ACON::Question::MultipleChoice.new "Who are your favorite superheros?", heros, "0,1"
      @helper.ask(input, @output, question).should eq ["Superman", "Batman"]

      question = ACON::Question::MultipleChoice.new "Who are your favorite superheros?", heros, " 0 , 1 "
      question.validator = nil
      @helper.ask(input, @output, question).should eq ["Superman", "Batman"]

      question = ACON::Question::MultipleChoice.new "Who are your favorite superheros?", heros, "0,Batman"
      @helper.ask(input, @output, question).should eq ["Superman", "Batman"]

      question = ACON::Question::MultipleChoice.new "Who are your favorite superheros?", heros
      @helper.ask(input, @output, question).should be_nil

      question = ACON::Question::MultipleChoice.new "Who are your favorite superheros?", {"a" => "Batman", "b" => "Superman"}, "a"
      @helper.ask(input, @output, question).should eq ["Batman"]

      begin
        question = ACON::Question::MultipleChoice.new "Who are your favorite superheros?", heros, ""
        @helper.ask input, @output, question
      rescue ex : ACON::Exceptions::InvalidArgument
        ex.message.should eq "Value '' is invalid."
      end
    end
  end
end
