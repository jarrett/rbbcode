require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestUnsupportedFeatures < Minitest::Test
  include RbbCode::OutputAssertions

  def test_remove_color_and_size_tags_to_html
    assert_converts_to(
      '<p>Not colored or resized but <strong>bold.</strong></p>',
      'Not [color=red]colored[/color] or [size=3]resized[/size] but [b]bold.[/b]',
      {}
    )
  end

  def test_remove_color_and_size_tags_to_markdown
    assert_converts_to(
      "Not colored or resized but **bold.**\n\n",
      'Not [color=red]colored[/color] or [size=3]resized[/size] but [b]bold.[/b]',
      { output_format: :markdown }
    )
  end

  def test_color_and_size_with_span_tags_to_html
    assert_converts_to(
      '<p>Not colored or resized but <strong>bold.</strong></p>',
      'Not [color=red]colored[/color] or [size=3]resized[/size] but [b]bold.[/b]',
      { :unsupported_features => :span }
    )
  end

  def test_color_and_size_with_tags_to_markdown
    assert_converts_to(
      "Not <span class=\"red\">colored</span> or <span class=\"size3\">resized</span> but **bold.**\n\n",
      'Not [color=red]colored[/color] or [size=3]resized[/size] but [b]bold.[/b]',
      { :unsupported_features => :span, output_format: :markdown }
    )
  end

end
