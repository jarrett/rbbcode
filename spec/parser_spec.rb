require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class MockSubclass
	@@received = []
	
	def initialize(*args)
		# Don't do anything
	end
	
	def method_missing(meth, *args)
		@@received << meth.to_sym
	end
	
	def self.received?(meth)
		@@received.include?(meth.to_sym)
	end
end

describe RbbCode::Parser do
	context 'parse_bb_code' do
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
			@parser.parse('Visit [url]http://google.com[/url] now').should == 'Visit <a href="http://google.com">http://google.com</a> now'
		end
		
		it 'should turn [url=http://google.com]Google[/url] to a link' do
			@parser.parse('Visit [url=http://google.com]Google[/url] now').should == 'Visit <a href="http://google.com">Google</a> now'
		end
		
		it 'should turn [img] to <img>' do
			@parser.parse('[img]http://example.com/image.jpg[/img]').should == '<img src="http://example.com/image.jpg" alt=""/>'
		end
		
		it 'should turn [code] to <code>' do
			@parser.parse('Too bad [code]method_missing[/code] is rarely useful').should == 'Too bad <code>method_missing</code> is rarely useful'
		end
		
		it 'should parse nested tags' do
			@parser.parse('[b][i]This is bold-italic[/i][/b]').should == '<strong></em>This is bold-italic</em></strong>'
		end
		
		it 'should ignore forbidden or unrecognized tags' do
			@parser.parse('There is [foo]no such thing[/foo] as a foo tag').should == 'There is no such thing as a foo tag'
		end
		
		it 'should ignore improperly matched tags' do
			@parser.parse('This [i]i tag[i] is not properly matched').should == 'This [i]i tag[i] is not properly matched'
			@parser.parse('This i tag[/i] is not properly matched').should == 'This i tag[/i] is not properly matched'
		end
		
		it 'should ignore badly malformed tags' do
			@parser.parse('This [i/]tag[/i] is malformed').should == 'This [i/]tag[/i] is malformed'
			@parser.parse('This [i]]tag[/i] is malformed').should == 'This [i]]tag[/i] is malformed'
			@parser.parse('This [i]tag[[/i] is malformed').should == 'This [i]tag[[/i] is malformed'
			@parser.parse('This [i]tag[//i] is malformed').should == 'This [i]tag[//i] is malformed'
		end
		
		it 'should recover gracefully from malformed tags that happen to contain well-formed tags' do
			@parser.parse('This [[i]tag[/i] is malformed').should == 'This [<em>tag</em> is malformed'
			@parser.parse('This [i]tag[/i]] is malformed').should == 'This <em>tag</em>] is malformed'
		end
		
		it 'should escape < and >' do
			@parser.parse('This is [i]italic[/i], but this it not <i>italic</i>.').should == 'This is <i>italic</i>, but this it not &lt;i&gt;italic&lt;/i&gt;.'
		end
		
		it 'should work when the string begins with a tag' do
			@parser.parse('[b]This is bold[/b]').should == '<strong>This is bold</strong>'
		end
		
		it 'should use the specified tokenizer subclass' do
			@parser = RbbCode::Parser.new({:tokenizer_class => MockSubclass})
			begin
				@parser.parse('This is [b]bold[/b] text')
			ensure
				MockSubclass.received?(:tokenize).should be_true
			end
		end
		
		it 'should use the specified cleaner subclass' do
			@parser = RbbCode::Parser.new({:cleaner_class => MockSubclass})
			begin
				@parser.parse('This is [b]bold[/b] text')
			ensure
				MockSubclass.received?(:clean).should be_true
			end
		end
		
		it 'should use the specified HTML-maker subclass' do
			@parser = RbbCode::Parser.new({:html_maker_class => MockSubclass})
			begin
				@parser.parse('This is [b]bold[/b] text')
			ensure
				MockSubclass.received?(:make_html).should be_true
			end
		end
	end
end