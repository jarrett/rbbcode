require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestCode < Minitest::Test
  include RbbCode::Heredoc
  include RbbCode::OutputAssertions

  def test_empty_code_to_html
    assert_converts_to(
      '<code></code>',
      '[code][/code]'
    )
  end

  def test_single_line_code_to_html
    assert_converts_to(
      '<code><p>Quoth the raven</p></code>',
      '[code]Quoth the raven[/code]'
    )
  end

  def test_multi_line_code_to_html
    assert_converts_to(
      '<code><p>Quoth the</p><p>raven</p></code>',
      heredoc(%(
        [code]Quoth
        the

        raven[/code]
      ))
    )
  end

  def test_empty_code_to_markdown
    assert_converts_to(
      "    \n\n",
      '[code][/code]',
      output_format: :markdown
    )
  end

  def test_single_line_code_to_markdown
    assert_converts_to(
      "    Quoth the raven\n\n",
      '[code]Quoth the raven[/code]',
      output_format: :markdown
    )
  end

  def test_multi_line_code_to_markdown
    assert_converts_to(
      "    Quoth\n    the\n    \n    raven\n\n",
      heredoc(%(
        [code]Quoth
        the

        raven[/code]
      )),
      output_format: :markdown
    )
  end

  # Test that we can handle arbitrary line breaks before or after the inner BBCode.
  def test_pre_and_post_breaks
    0.upto(3) do |pre_breaks|
      0.upto(3).each do |post_breaks|
        bb_code = '[code]' + ("\n" * pre_breaks) + 'Quoth the raven' + ("\n" * post_breaks) + '[/code]'
        assert_converts_to(
          '<code><p>Quoth the raven</p></code>',
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
        bb_code = '[code]' + ("\n" * pre_breaks) + inner + ("\n" * post_breaks) + '[/code]'
        assert_converts_to(
          '<code>
            <p>Quoth</p>
            <p>the</p>
            <p>raven</p>
          </code>',
          bb_code,
          {},
          "HTML output not correct for #{pre_breaks} pre-break(s) and #{post_breaks} post-break(s)."
        )
      end
    end
  end
end
