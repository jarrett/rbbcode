require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestBlockquotes < Minitest::Test
  include RbbCode::HTMLAssertions
  
  def test_blockquotes
    0.upto(3) do |pre_breaks|
      0.upto(3).each do |post_breaks|
        bb_code = '[quote]' + ("\n" * pre_breaks) + 'Quoth the raven' + ("\n" * post_breaks) + '[/quote]'
        assert_converts_to(
          '<blockquote><p>Quoth the raven</p></blockquote>',
          bb_code,
          {},
          "#{bb_code} did not convert properly"
        )
      end
    end
    
    0.upto(3) do |pre_breaks|
      0.upto(3).each do |post_breaks|
        bb_code = '[quote]' + ("\n" * pre_breaks) + "Quoth\n\nthe\n\nraven" + ("\n" * post_breaks) + '[/quote]'
        assert_converts_to(
          '<blockquote>
            <p>Quoth</p>
            <p>the</p>
            <p>raven</p>
          </blockquote>',
          bb_code,
          {},
          "#{bb_code} did not convert properly"
        )
      end
    end
  end
end