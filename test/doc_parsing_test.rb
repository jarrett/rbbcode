require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestDocParsing < Minitest::Test
  include RbbCode::StringAssertions

  def given_bb_code
    <<-EOS
[b]This [i]is[/i] awesome[/b]

Another paragraph. And something [u]underlined[/u].

A paragraph with
a line break.

Here\'s one kind of link: [url]http://example.org[/url]

Here\'s another: [url=http://example.com]Example[/url]

This is an image: [img]http://example.com/foo.png[/img]

[quote]
This [i]is[/i] a
quotation.

Yes it is.
[/quote]

[list] [*]Entry 1 [*]Entry 2
[*]Entry 3
[/list]

Smile: :) Frown: :(
    EOS
  end

  def expected_html
    <<-EOS

        <p><strong>This <em>is</em> awesome</strong></p>
        <p>Another paragraph. And something <u>underlined</u>.</p>
        <p>A paragraph with<br/>a line break.</p>
        <p>Here\'s one kind of link: <a href="http://example.org">http://example.org</a></p>
        <p>Here\'s another: <a href="http://example.com">Example</a></p>
        <p>This is an image: <img src="http://example.com/foo.png" alt="Image"/></p>

        <blockquote>
          <p>This <em>is</em> a quotation.</p>

          <p>Yes it is.</p>
        </blockquote>

        <ul>
          <li>Entry 1</li>
          <li>Entry 2</li>
          <li>Entry 3</li>
        </ul>
        <p>Smile: <img src="/happy.png" alt="Emoticon"/> Frown: <img src="/sad.png" alt="Emoticon"/></p>

    EOS
  end

  def expected_markdown
    <<-EOS
**This *is* awesome**

Another paragraph.

A paragraph with a line break. And something <u>underlined</u>.

Here\'s one kind of link: [http://example.org](http://example.org)

Here\'s another: [Example](http://example.com)

This is an image: ![Image](http://example.com/foo.png)

>  This *is* a quotation.
>
>  Yes it is.

* Entry 1
* Entry 2
* Entry 3

Smile: ![Emoticon](/happy.png) Frown: ![Emoticon](/sad.png)
    EOS
  end

  def test_parsing_whole_document_to_html
    assert_converts_to(
      expected_html, given_bb_code,
      # RbbCode options:
      :emoticons => {':)' => '/happy.png', ':(' => '/sad.png'}
    )
  end

  def test_parsing_whole_document_to_markdown
    assert_converts_to(
      expected_markdown, given_bb_code,
      # RbbCode options:
      :emoticons => {':)' => '/happy.png', ':(' => '/sad.png'},
      :to_markup => :markdown
    )
  end
end
