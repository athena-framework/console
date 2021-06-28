class Athena::Console::Helper::Formatter < Athena::Console::Helper
  def format_section(section : String, message : String, style : String = "info") : String
    "<#{style}>[#{section}]</#{style}> #{message}"
  end

  def format_block(messages : String | Enumerable(String), style : String, large : Bool = false)
    messages = messages.is_a?(String) ? {messages} : messages

    len = 0
    lines = [] of String

    messages.each do |message|
      message = ACON::Formatter::Output.escape message
      lines << (large ? "  #{message}  " : " #{message} ")
      len = Math.max (message.size + (large ? 4 : 2)), len
    end

    messages = large ? [" " * len] : [] of String

    lines.each do |line|
      messages << %(#{line}#{" " * (len - line.size)})
    end

    if large
      messages << " " * len
    end

    messages.each_with_index do |line, idx|
      messages[idx] = "<#{style}>#{line}</#{style}>"
    end

    messages.join '\n'
  end

  def truncate(message : String, length : Int, suffix : String = "...") : String
    computed_length = length - self.class.width suffix

    if computed_length > self.class.width message
      return message
    end

    "#{message[0...length]}#{suffix}"
  end
end
