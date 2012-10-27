require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestDocParsing < Test::Unit::TestCase
  include RbbCode::HTMLAssertions
  
  def test_parsing_whole_document
    assert_converts_to(
      # Expected HTML:
      '
        <p><strong>This <em>is</em> awesome</strong></p>
        <p>Another paragraph.</p>
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
      ',
      # BBCode:
      '
        [b]This [i]is[/i] awesome[/b]
        
        Another paragraph.
        
        A paragraph with
        a line break.
        
        Here\'s one kind of link: [url]http://example.org[/url]
        
        Here\'s another: [url=http://example.com]Example[/url]
        
        This is an image: [img]http://example.com/foo.png[/img]
        
        [quote]
        This [i]is[/i] a quotation.
        
        Yes it is.
        [/quote]
        
        [list] [*]Entry 1 [*]Entry 2
        [*]Entry 3
        [/list]
        
        Smile: :) Frown: :(
      ',
      # RbbCode options:
      :emoticons => {':)' => '/happy.png', ':(' => '/sad.png'}
    )
  end
end