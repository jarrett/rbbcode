require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestLinks < Minitest::Test
  include RbbCode::HTMLAssertions
  def test_complex_url_tag
    assert_converts_to(
      '<p><a href="http://example.com/foo/bar.html">Baz</a></p>',
      '[url="http://example.com/foo/bar.html"]Baz[/url]'
    )
  end
  
  def test_simple_url_tag
    assert_converts_to(
      '<p><a href="http://example.com/foo/bar.html">http://example.com/foo/bar.html</a></p>',
      '[url]http://example.com/foo/bar.html[/url]'
    )
  end
end