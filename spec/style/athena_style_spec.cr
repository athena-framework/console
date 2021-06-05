require "../spec_helper"

struct AthenaStyleTest < ASPEC::TestCase
  @col_size : String?

  def initialize
    @col_size = ENV["COLUMNS"]?
    ENV["COLUMNS"] = "121"
  end

  def tear_down : Nil
    if size = @col_size
      ENV["COLUMNS"] = size
    else
      ENV.delete "COLUMNS"
    end
  end

  private def assert_file_equals_string(filepath : String, string : String, *, file : String = __FILE__, line : Int32 = __LINE__) : Nil
    normalized_path = File.join __DIR__, "..", "fixtures", filepath
    string.should match(Regex.new(File.read(normalized_path))), file: file, line: line
  end

  @[DataProvider("output_provider")]
  def test_outputs(command_proc : ACON::Spec::MockCommand::Proc, file_path : String) : Nil
    command = ACON::Spec::MockCommand.new "foo", &command_proc

    tester = ACON::Spec::CommandTester.new command

    tester.execute interactive: false, decorated: false
    self.assert_file_equals_string file_path, tester.display
  end

  def output_provider : Hash
    {
      "Single blank line at start with block element" => {
        (ACON::Spec::MockCommand::Proc.new do |input, output|
          ACON::Style::Athena.new(input, output).caution "Lorem ipsum dolor sit amet"

          ACON::Command::Status::SUCCESS
        end),
        "style/block.txt",
      },
      "Single blank line between titles and blocks" => {
        (ACON::Spec::MockCommand::Proc.new do |input, output|
          style = ACON::Style::Athena.new input, output
          style.title "Title"
          style.warning "Lorem ipsum dolor sit amet"
          style.title "Title"

          ACON::Command::Status::SUCCESS
        end),
        "style/title_block.txt",
      },
      "Single blank line between blocks" => {
        (ACON::Spec::MockCommand::Proc.new do |input, output|
          style = ACON::Style::Athena.new input, output
          style.warning "Warning"
          style.caution "Caution"
          style.error "Error"
          style.success "Success"
          style.note "Note"
          style.info "Info"
          style.block "Custom block", "CUSTOM", style: "fg=white;bg=green", prefix: "X ", padding: true

          ACON::Command::Status::SUCCESS
        end),
        "style/blocks.txt",
      },
      "Single blank line between titles" => {
        (ACON::Spec::MockCommand::Proc.new do |input, output|
          style = ACON::Style::Athena.new input, output
          style.title "First title"
          style.title "Second title"

          ACON::Command::Status::SUCCESS
        end),
        "style/titles.txt",
      },
      "Single blank line after any text and a title" => {
        (ACON::Spec::MockCommand::Proc.new do |input, output|
          style = ACON::Style::Athena.new input, output
          style.print "Lorem ipsum dolor sit amet"
          style.title "First title"

          style.puts "Lorem ipsum dolor sit amet"
          style.title "Second title"

          style.print "Lorem ipsum dolor sit amet"
          style.print ""
          style.title "Third title"

          # Handle edge case by appending empty strings to history
          style.print "Lorem ipsum dolor sit amet"
          style.print({"", "", ""})
          style.title "Fourth title"

          # Ensure manual control over number of blank lines
          style.puts "Lorem ipsum dolor sit amet"
          style.puts({"", ""}) # Should print 1 extra newline
          style.title "Fifth title"

          style.puts "Lorem ipsum dolor sit amet"
          style.new_line 2 # Should print 1 extra newline
          style.title "Sixth title"

          ACON::Command::Status::SUCCESS
        end),
        "style/titles_text.txt",
      },
      "Proper line endings before outputting a text block" => {
        (ACON::Spec::MockCommand::Proc.new do |input, output|
          style = ACON::Style::Athena.new input, output
          style.puts "Lorem ipsum dolor sit amet"
          style.listing "Lorem ipsum dolor sit amet", "consectetur adipiscing elit"

          # When using print
          style.print "Lorem ipsum dolor sit amet"
          style.listing "Lorem ipsum dolor sit amet", "consectetur adipiscing elit"

          style.print "Lorem ipsum dolor sit amet"
          style.text({"Lorem ipsum dolor sit amet", "consectetur adipiscing elit"})

          style.new_line

          style.print "Lorem ipsum dolor sit amet"
          style.comment({"Lorem ipsum dolor sit amet", "consectetur adipiscing elit"})

          ACON::Command::Status::SUCCESS
        end),
        "style/block_line_endings.txt",
      },
      "Proper blank line after text block with block" => {
        (ACON::Spec::MockCommand::Proc.new do |input, output|
          style = ACON::Style::Athena.new input, output
          style.listing "Lorem ipsum dolor sit amet", "consectetur adipiscing elit"
          style.success "Lorem ipsum dolor sit amet"

          ACON::Command::Status::SUCCESS
        end),
        "style/text_block_blank_line.txt",
      },
      "Questions do not output anything when input is non-interactive" => {
        (ACON::Spec::MockCommand::Proc.new do |input, output|
          style = ACON::Style::Athena.new input, output
          style.title "Title"
          style.ask_hidden "Hidden question"
          style.choice "Choice question with default", {"choice1", "choice2"}, "choice1"
          style.confirm "Confirmation with yes default", true
          style.text "Duis aute irure dolor in reprehenderit in voluptate velit esse"

          ACON::Command::Status::SUCCESS
        end),
        "style/non_interactive_question.txt",
      },
      # TODO: Test table formatting with multiple headers + TableCell
      "Lines are aligned to the beginning of the first line in a multi-line block" => {
        (ACON::Spec::MockCommand::Proc.new do |input, output|
          ACON::Style::Athena.new(input, output).block({"Custom block", "Second custom block line"}, "CUSTOM", style: "fg=white;bg=green", prefix: "X ", padding: true)

          ACON::Command::Status::SUCCESS
        end),
        "style/multi_line_block.txt",
      },
      "Lines are aligned to the beginning of the first line in a very long line block" => {
        (ACON::Spec::MockCommand::Proc.new do |input, output|
          ACON::Style::Athena.new(input, output).block(
            "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum",
            "CUSTOM",
            style: "fg=white;bg=green",
            prefix: "X ",
            padding: true
          )

          ACON::Command::Status::SUCCESS
        end),
        "style/long_line_block.txt",
      },
      "Long lines are wrapped within a block" => {
        (ACON::Spec::MockCommand::Proc.new do |input, output|
          ACON::Style::Athena.new(input, output).block(
            "Lopadotemachoselachogaleokranioleipsanodrimhypotrimmatosilphioparaomelitokatakechymenokichlepikossyphophattoperisteralektryonoptekephalliokigklopeleiolagoiosiraiobaphetraganopterygon",
            "CUSTOM",
            style: "fg=white;bg=green",
            prefix: " § ",
          )

          ACON::Command::Status::SUCCESS
        end),
        "style/long_line_block_wrapping.txt",
      },
    }
  end
end
