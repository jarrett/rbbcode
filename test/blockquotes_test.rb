require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestBlockquotes < Minitest::Test
  include RbbCode::Heredoc
  include RbbCode::OutputAssertions

  def test_empty_blockquote_to_html
    assert_converts_to(
      '<blockquote></blockquote>',
      '[quote][/quote]'
    )
  end

  def test_single_line_blockquote_to_html
    assert_converts_to(
      '<blockquote><p>Quoth the raven</p></blockquote>',
      '[quote]Quoth the raven[/quote]'
    )
  end

  def test_multi_line_blockquote_to_html
    assert_converts_to(
      '<blockquote><p>Quoth the</p><p>raven</p></blockquote>',
      heredoc(%(
        [quote]Quoth
        the 

        raven[/quote]
      ))
    )
  end

  def test_empty_blockquote_to_markdown
    assert_converts_to(
      "> \n\n",
      '[quote][/quote]',
      output_format: :markdown
    )
  end

  def test_single_line_blockquote_to_markdown
    assert_converts_to(
      "> Quoth the raven\n\n",
      '[quote]Quoth the raven[/quote]',
      output_format: :markdown
    )
  end

  def test_multi_line_blockquote_to_markdown
    assert_converts_to(
      heredoc(%(
        > Quoth
        > the
        > 
        > raven


      )),
      heredoc(%(
        [quote]Quoth
        the

        raven[/quote]
      )),
      output_format: :markdown
    )
  end

  # Test that we can handle arbitrary line breaks before or after the inner BBCode.
  def test_pre_and_post_breaks
    0.upto(3) do |pre_breaks|
      0.upto(3).each do |post_breaks|
        bb_code = '[quote]' + ("\n" * pre_breaks) + 'Quoth the raven' + ("\n" * post_breaks) + '[/quote]'
        assert_converts_to(
          '<blockquote><p>Quoth the raven</p></blockquote>',
          bb_code,
          {},
          "HTML output not correct for #{pre_breaks} pre-break(s) and #{post_breaks} post-break(s)."
        )
      end
    end

    0.upto(3) do |pre_breaks|
      0.upto(3).each do |post_breaks|
        inner = heredoc(%(
          Quoth

          the

          raven
        ))
        bb_code = '[quote]' + ("\n" * pre_breaks) + inner + ("\n" * post_breaks) + '[/quote]'
        assert_converts_to(
          '<blockquote>
            <p>Quoth</p>
            <p>the</p>
            <p>raven</p>
          </blockquote>',
          bb_code,
          {},
          "HTML output not correct for #{pre_breaks} pre-break(s) and #{post_breaks} post-break(s)."
        )
      end
    end
  end
end
