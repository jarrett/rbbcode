require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestBlockquotes < Minitest::Test
  include RbbCode::StringAssertions

  # Based on bug report:
  # https://github.com/jarrett/rbbcode/issues/17
  def test_badly_nested_quote_and_size_to_html
    bb_code = '[quote]this is [size]large text[/quote][/size]'
    bb_code = '[quote][size][/quote][/size]'
    assert_converts_to(
      "<blockquote>\n<p>[size]</p>\n</blockquote>\n[/size]",
      bb_code,
      {},
      "#{bb_code} did not convert properly"
    )
  end

    def test_badly_nested_quote_and_size_to_markdown
    bb_code = '[quote]this is [size]large text[/quote][/size]'
    bb_code = '[quote][size][/quote][/size]'
    assert_converts_to(
      "> [size]\n\n[/size]",
      bb_code,
      { :to_markup => :markdown },
      "#{bb_code} did not convert properly"
    )
  end
end
