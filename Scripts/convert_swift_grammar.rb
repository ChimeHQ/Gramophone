require "open-uri"
require "redcarpet"

class SwiftEBNF < Redcarpet::Render::Base
  # Methods where the first argument is the text content
  [
    # block-level calls
    :block_code, :block_quote,
    :block_html, :list, :list_item,
    :paragraph,

    # span-level calls
    :autolink, :double_emphasis,
    :emphasis, :underline, :raw_html,
    :triple_emphasis, :strikethrough,
    :superscript, :highlight, :quote,

    # footnotes
    :footnotes, :footnote_def, :footnote_ref,

    # low level rendering
    :entity, :normal_text
  ].each do |method|
    define_method method do |*args|
      args.first
    end
  end

  # unhandled
  # :header, :image, :link, :table, :table_row, :table_cell

  def codespan(text)
    if text.include?("'")
      "\"#{text}\""
    else
      "'#{text}'"
    end
  end
end

data = URI.parse("https://raw.githubusercontent.com/swiftlang/swift-book/refs/heads/main/TSPL.docc/ReferenceManual/SummaryOfTheGrammar.md").read

markdown_rules = data
  .lines
  .filter { |line| line.include?("→") }
  .map { |x| x.gsub(" \\\n", "\n") } # remove any trailing backslashes
  .join

markdown = Redcarpet::Markdown.new(SwiftEBNF)

puts markdown.render(markdown_rules)