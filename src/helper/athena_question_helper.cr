abstract class Athena::Console::Helper; end

require "./question"

class Athena::Console::Helper::AthenaQuestionHelper < Athena::Console::Helper::Question
  protected def write_prompt(output : ACON::Output::Interface, question : ACON::Question) : Nil
    text = ACON::Formatter::OutputFormatter.escape_trailing_backslash question.question
    default = question.default

    # TODO: Handle multi line questions

    text = if default.nil?
             " <info>#{text}</info>"
           elsif question.is_a? ACON::Question::Confirmation
             %( <info>#{text} (yes/no)</info> [<comment>#{default ? "yes" : "no"}</comment>])
           elsif question.is_a? ACON::Question::Choice && question.multi_select?
             ""
           elsif question.is_a? ACON::Question::Choice
             ""
           else
             " <info>#{text}</info> [<comment>#{ACON::Formatter::OutputFormatter.escape default.to_s}</comment>]"
           end

    output.puts text

    prompt = " > "

    if question.is_a? ACON::Question::Choice
      output.puts self.format_choice_question_choices question, "comment"

      prompt = question.prompt
    end

    output.print prompt
  end
end
