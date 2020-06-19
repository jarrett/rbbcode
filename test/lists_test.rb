require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestLists < Minitest::Test
  include RbbCode::Heredoc
  include RbbCode::OutputAssertions
  
  def test_lists_to_html
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
            "HTML output not correct with #{pre_breaks} pre break(s), #{post_breaks} post break(s), and #{inner_breaks} inner break(s)."
          )
        end
      end
    end
  end

  def test_lists_to_markdown
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
            heredoc(%(
              * 1
              * 2
              * 3
            )),
            bb_code,
            {output_format: :markdown},
            "Markdown output not correct with #{pre_breaks} pre break(s), #{post_breaks} post break(s), and #{inner_breaks} inner break(s)."
          )
        end
      end
    end
  end
end