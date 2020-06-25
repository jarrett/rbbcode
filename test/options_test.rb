require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestOptions < Minitest::Test
  def test_override_in_convert
    rbbcode = RbbCode.new(output_format: :html)
    output = rbbcode.convert('Foo [i]bar[/i] baz', output_format: :markdown).strip
    assert_equal('Foo *bar* baz', output)
  end
end