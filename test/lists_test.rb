require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestLists < Test::Unit::TestCase
  include RbbCode::HTMLAssertions
  
  def test_lists
    0.upto(3) do |pre_breaks|
      0.upto(3).each do |post_breaks|
        0.upto(3).each do |inner_breaks|
          bb_code = '[list]' + ("\n" * pre_breaks) +
            '[*] 1' + ("\n" * inner_breaks) +
            '[*] 2' + ("\n" * inner_breaks) +
            '[*] 3' + ("\n" * inner_breaks) +
            ("\n" * post_breaks) +
            '[/list]'
          assert_converts_to(
            '<ul>
              <li>1</li>
              <li>2</li>
              <li>3</li>
            </ul>',
            bb_code,
            {},
            "#{bb_code} did not convert properly"
          )
        end
      end
    end
  end
end