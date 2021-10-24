require "./question_base"

# This namespaces contains various questions that can be asked via the `ACON::Helper::Question` helper or `ART::Style::Athena` style.
#
# This class can also be used to ask the user for more information in the most basic form, a simple question and answer.
#
# ## Usage
#
# ```
# question = ACON::Question(String?).new "What is your name?", nil
# name = helper.ask input, output, question
# ```
#
# This will prompt to user to enter their name. If they do not enter valid input, the default value of `nil` will be used.
# The default can be customized, ideally with sane defaults to make the UX better.
#
# ### Trimming the Answer
#
# By default the answer is [trimmed](https://crystal-lang.org/api/String.html#strip%3AString-instance-method) in order to remove leading and trailing whitespace.
# The `ACON::Question::QuestionBase#trimmable=` method can be used to disable this if you need the input as is.
#
# ```
# question = ACON::Question(String?).new "What is your name?", nil
# question.trimmable = false
# name_with_whitespace_and_newline = helper.ask input, output, question
# ```
#
# ### Multiline Input
#
# The question helper will stop reading input when it receives a newline character. I.e. the user presses the `ENTER` key.
# However in some cases you may want to allow for an answer that spans multiple lines.
# The `ACON::Question::QuestionBase#multi_line=` method can be used to enable multi line mode.
#
# ```
# question = ACON::Question(String?).new "Tell me a story.", nil
# question.multi_line = true
# ```
#
# Multiline questions stop reading user input after receiving an end-of-transmission control character. (`Ctrl+D` on Unix systems).
#
# ### Hiding User Input
#
# If your question is asking for sensitive information, such as a password, you can set a question to hidden.
# This will make it so the input string is not displayed on the terminal, which is equivalent to how password are handled on Unix systems.
#
# ```
# question = ACON::Question(String?).new "What is your password?.", nil
# question.hidden = true
# ```
#
# WARNING: If no method to hide the response is available on the underlying system/input, it will fallback and allow the response to be seen.
# If having the hidden response hidden is vital, you _MUST_ set `ACON::Question::QuestionBase#hidden_fallback=` to `false`; which will
# raise an exception instead of allowing the input to be visible.
#
# ### Normalizing the Answer
#
# ### Validating the Answer
#
# #### Hidden Response
#
# ### Testing a Command that Expects Input
#
# ### Autocompletion
#
# TODO: Implement this.
class Athena::Console::Question(T)
  include Athena::Console::Question::QuestionBase(T)

  property validator : Proc(T, T)? = nil

  def set_validator(&@validator : T -> T) : Nil
  end
end
