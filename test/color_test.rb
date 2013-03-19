require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestColorParsing < Test::Unit::TestCase
  include RbbCode::HTMLAssertions
  
  def test_parse_text_content
    assert_converts_to(
      # Expected HTML:
      '<p><span style="color:red;">This is red text</span></p>',
      # BBCode:
      '[color=red]This is red text[/color]'
    )
  end
  
  def test_downcase_color
    assert_converts_to(
      # Expected HTML:
      '<p><span style="color:red;">This is red text</span></p>',
      # BBCode:
      '[color=RED]This is red text[/color]'
    )
  end
  
  def test_parse_tag_content
    assert_converts_to(
      # Expected HTML:
      '<p><span style="color:red;"><em>This is red italic text</em></span></p>',
      # BBCode:
      '[color=red][i]This is red italic text[/i][/color]'
    )
  end
end