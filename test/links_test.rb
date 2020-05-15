require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestLinks < Minitest::Test
  include RbbCode::StringAssertions

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

  def test_complex_url_tag_to_markdown
    assert_converts_to(
      "[Baz](http://example.com/foo/bar.html)\n",
      '[url="http://example.com/foo/bar.html"]Baz[/url]',
      :to_markup => :markdown
    )
  end

  def test_simple_url_tag_to_markdown
    assert_converts_to(
      "[http://example.com/foo/bar.html](http://example.com/foo/bar.html)\n",
      '[url]http://example.com/foo/bar.html[/url]',
      :to_markup => :markdown
    )
  end
end
