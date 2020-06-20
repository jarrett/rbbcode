require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestLinks < Minitest::Test
  include RbbCode::OutputAssertions
  
  def test_complex_url_tag_to_html
    assert_converts_to(
      '<p><a href="http://example.com/foo/bar.html">Baz</a></p>',
      '[url="http://example.com/foo/bar.html"]Baz[/url]'
    )
  end
  
  def test_simple_url_tag_to_html
    assert_converts_to(
      '<p><a href="http://example.com/foo/bar.html">http://example.com/foo/bar.html</a></p>',
      '[url]http://example.com/foo/bar.html[/url]'
    )
  end

  def test_simple_url_tag_to_markdown
    assert_converts_to(
      "Foo [http://example.com/foo/bar.html](http://example.com/foo/bar.html) bar\n\n",
      'Foo [url]http://example.com/foo/bar.html[/url] bar',
      output_format: :markdown
    )
  end

  def test_complex_url_tag_to_markdown
    assert_converts_to(
      "Foo [Baz](http://example.com/foo/bar.html) bar\n\n",
      'Foo [url="http://example.com/foo/bar.html"]Baz[/url] bar',
      output_format: :markdown
    )
  end
end