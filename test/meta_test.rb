require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestLists < Minitest::Test
  include RbbCode::Heredoc

  def test_heredoc
    output = heredoc(%(
      foo
        bar
      baz
    ))
    assert_equal("foo\n  bar\nbaz", output)
  end
end