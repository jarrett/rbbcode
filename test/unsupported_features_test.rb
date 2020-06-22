require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestUnsupportedFeatures < Minitest::Test
  include RbbCode::OutputAssertions

  def test_remove_color_tag_to_html
    assert_converts_to(
      '<p>Not colored but <strong>bold.</strong></p>',
      'Not [color=red]colored[/color] but [b]bold.[/b]',
      {}
    )
  end

  def test_remove_color_tag_to_markdown
    assert_converts_to(
      "Not colored but **bold.**\n\n",
      'Not [color=red]colored[/color] but [b]bold.[/b]',
      { output_format: :markdown }
    )
  end

  def test_remove_size_tag_to_html
    assert_converts_to(
      '<p>Not resized but <strong>bold.</strong></p>',
      'Not [size=3]resized[/size] but [b]bold.[/b]',
      {}
    )
  end

  def test_remove_size_tag_to_markdown
    assert_converts_to(
      "Not resized but **bold.**\n\n",
      'Not [size=3]resized[/size] but [b]bold.[/b]',
      { output_format: :markdown }
    )
  end
end
