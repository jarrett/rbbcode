require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestBlockquotes < Minitest::Test
  include RbbCode::StringAssertions

  def test_blockquotes_to_html
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

  def test_blockquotes_to_markdown
    0.upto(3) do |pre_breaks|
      0.upto(3).each do |post_breaks|
        bb_code = '[quote]' + ("\n" * pre_breaks) + 'Quoth the raven' + ("\n" * post_breaks) + '[/quote]'
        assert_converts_to(
          '\n> Quoth the raven\n',
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
          "\n> Quoth\n> \n> the\n> \n> raven\n",
          bb_code,
          {},
          "#{bb_code} did not convert properly"
        )
      end
    end
  end
end
