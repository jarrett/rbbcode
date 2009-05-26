require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RbbCode::Parser do
	context '#parse_bb_code' do
		before :each do
			@parser = RbbCode::Parser.new
		end
		
		it 'should create paragraphs and line breaks' do
			bb_code = "This is one paragraph.\n\nThis is another paragraph."
			@parser.parse(bb_code).should == '<p>This is one line.</p><p>This is another line.</p>'
			bb_code = "This is one line.\nThis is another line."
			@parser.parse(bb_code).should == '<p>This is one line.<br/>This is another line.</p>'
		end
		
		it 'should turn [b] to <strong>' do
			@parser.parse('This is [b]bold[/b] text').should == '<p>This is <strong>bold</strong> text</p>'
		end
		
		it 'should turn [i] to <em> by default' do
			@parser.parse('This is [i]italic[/i] text').should == '<p>This is <em>italic</em> text</p>'
		end
		
		it 'should turn [u] to <u>' do
			@parser.parse('This is [u]underlined[/u] text').should == '<p>This is <u>underlined</u> text</p>'
		end
		
		it 'should turn [url]http://google.com[/url] to a link' do
			@parser.parse('Visit [url]http://google.com[/url] now').should == '<p>Visit <a href="http://google.com">http://google.com</a> now</p>'
		end
		
		it 'should turn [url=http://google.com]Google[/url] to a link' do
			@parser.parse('Visit [url=http://google.com]Google[/url] now').should == '<p>Visit <a href="http://google.com">Google</a> now</p>'
		end
		
		it 'should turn [img] to <img>' do
			@parser.parse('[img]http://example.com/image.jpg[/img]').should == '<p><img src="http://example.com/image.jpg" alt=""/></p>'
		end
		
		it 'should turn [code] to <code>' do
			@parser.parse('Too bad [code]method_missing[/code] is rarely useful').should == '<p>Too bad <code>method_missing</code> is rarely useful</p>'
		end
		
		it 'should parse nested tags' do
			@parser.parse('[b][i]This is bold-italic[/i][/b]').should == '<p><strong><em>This is bold-italic</em></strong></p>'
		end
		
		it 'should not put <p> tags around <ul> tags' do
			@parser.parse("Text.\n\n[list]\n[*]Foo[/*]\n[*]Bar[/*]\n[/list]\n\nMore text.").should == '<p>Text</p><ul><li>Foo</li><li>Bar</li></ul><p>More text.</p>'
		end
		
		it 'should ignore forbidden or unrecognized tags' do
			@parser.parse('There is [foo]no such thing[/foo] as a foo tag').should == '<p>There is no such thing as a foo tag</p>'
		end
		
		it 'should ignore improperly matched tags' do
			# By default, the [i] tag cannot be nested, so
			@parser.parse('This [i]i tag[i] is not properly matched').should == '<p>This [i]i tag[i] is not properly matched</p>'
			@parser.parse('This i tag[/i] is not properly matched').should == '<p>This i tag[/i] is not properly matched</p>'
		end
		
		it 'should recover gracefully from malformed tags' do
			@parser.parse('This [i/]tag[/i] is malformed').should == '<p>This [i/]tag is malformed</p>'
			@parser.parse('This [i]]tag[/i] is malformed').should == '<p>This <em>]tag</em> is malformed</p>'
			@parser.parse('This [i]tag[[/i] is malformed').should == '<p>This <em>tag[</em> is malformed</p>'
			@parser.parse('This [i]tag[//i] is malformed').should == '<p>This <em>tag[//i] is malformed</em></p>'
			@parser.parse('This [[i]tag[/i] is malformed').should == '<p>This [<em>tag</em> is malformed</p>'
			@parser.parse('This [i]tag[/i]] is malformed').should == '<p>This <em>tag</em>] is malformed</p>'
		end
		
		it 'should escape < and >' do
			@parser.parse('This is [i]italic[/i], but this it not <i>italic</i>.').should == '<p>This is <em>italic</em>, but this it not &lt;i&gt;italic&lt;/i&gt;.</p>'
		end
		
		it 'should work when the string begins with a tag' do
			@parser.parse('[b]This is bold[/b]').should == '<p><strong>This is bold</strong></p>'
		end
	end
end