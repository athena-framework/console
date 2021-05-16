require "../spec_helper"

@[ASPEC::TestCase::Focus]
struct OutputFormatterTest < ASPEC::TestCase
  @formatter : ACON::Formatter::OutputFormatter

  def initialize
    @formatter = ACON::Formatter::OutputFormatter.new true
  end

  def test_empty_tag : Nil
    @formatter.format("foo<>bar").should eq "foo<>bar"
  end

  def test_lg_char_escaping : Nil
    @formatter.format("foo\\<bar").should eq "foo<bar"
    @formatter.format("foo << bar").should eq "foo << bar"
    @formatter.format("foo << bar \\").should eq "foo << bar \\"
    @formatter.format("foo << <info>bar \\ baz</info> \\").should eq "foo << \e[32mbar \\ baz\e[0m \\"
    @formatter.format("\\<info>some info\\</info>").should eq "<info>some info</info>"
    ACON::Formatter::OutputFormatter.escape("<info>some info</info>").should eq "\\<info>some info\\</info>"

    @formatter.format("<comment>Some\\Path\\ToFile does work very well!</comment>").should eq "\e[33mSome\\Path\\ToFile does work very well!\e[0m"
  end

  def test_built_in_styles : Nil
    @formatter.has_style?("error").should be_true
    @formatter.has_style?("info").should be_true
    @formatter.has_style?("comment").should be_true
    @formatter.has_style?("question").should be_true

    @formatter.format("<error>some error</error>").should eq "\e[97;41msome error\e[0m"
    @formatter.format("<info>some info</info>").should eq "\e[32msome info\e[0m"
    @formatter.format("<comment>some comment</comment>").should eq "\e[33msome comment\e[0m"
    @formatter.format("<question>some question</question>").should eq "\e[30;46msome question\e[0m"
  end

  # TODO: Dependent on https://github.com/crystal-lang/crystal/issues/10652.
  def ptest_nested_styles : Nil
    @formatter.format("<error>some <info>some info</info> error</error>").should eq "\e[37;41msome \e[39;49m\e[32msome info\e[39m\e[37;41m error\e[39;49m"
  end

  # TODO: Dependent on https://github.com/crystal-lang/crystal/issues/10652.
  def ptest_deeply_nested_styles : Nil
    @formatter.format("<error>error<info>info<comment>comment</info>error</error>").should eq "\e[37;41merror\e[39;49m\e[32minfo\e[39m\e[33mcomment\e[39m\e[37;41merror\e[39;49m"
  end

  def test_adjacent_styles : Nil
    @formatter.format("<error>some error</error><info>some info</info>").should eq "\e[97;41msome error\e[0m\e[32msome info\e[0m"
  end

  def test_adjacent_styles_not_greedy : Nil
    @formatter.format("(<info>>=2.0,<2.3</info>)").should eq "(\e[32m>=2.0,<2.3\e[0m)"
  end

  def test_style_escaping : Nil
    @formatter.format(%((<info>#{@formatter.class.escape "z>=2.0,<\\<<a2.3\\"}</info>))).should eq "(\e[32mz>=2.0,<<<a2.3\\\e[0m)"
    @formatter.format(%(<info>#{@formatter.class.escape "<error>some error</error>"}</info>)).should eq "\e[32m<error>some error</error>\e[0m"
  end

  def test_custom_style : Nil
    style = ACON::Formatter::OutputFormatterStyle.new :blue, :white
    @formatter.set_style "test", style

    @formatter.style("test").should eq style
    @formatter.style("info").should_not eq style

    style = ACON::Formatter::OutputFormatterStyle.new :blue, :white
    @formatter.set_style "b", style

    @formatter.format("<test>some message</test><b>custom</b>").should eq "\e[34;107msome message\e[0m\e[34;107mcustom\e[0m"
    # TODO: Also assert it works when nested.
  end

  def test_redefine_style : Nil
    style = ACON::Formatter::OutputFormatterStyle.new :blue, :white
    @formatter.set_style "info", style

    @formatter.format("<info>some custom message</info>").should eq "\e[34;107msome custom message\e[0m"
  end

  def test_inline_style : Nil
    @formatter.format("<fg=blue;bg=red>some text</>").should eq "\e[34;41msome text\e[0m"
    @formatter.format("<fg=blue;bg=red>some text</fg=blue;bg=red>").should eq "\e[34;41msome text\e[0m"
  end
end
