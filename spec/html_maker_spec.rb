require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RbbCode::HtmlMaker do
	include TokenTestHelper
	
	it 'should replace all tags given to it' do
		input = make_tokens([
			[:text, 'This is '],
			[:opening_tag, '[b]'],
			[:text, 'bold'],
			[:closing_tag, '[/b]'],
			[:text, ' text']
		])
		
		maker = RbbCode::HtmlMaker.new
		
		maker.make_html(input).should == 'This is <strong>bold</strong> text'
	end
	
	it 'should work for nested tags' do
		input = make_tokens([
			[:text, 'This '],
			[:opening_tag, '[b]'],
			[:text, 'text is bold '],
			[:opening_tag, '[u]'],
			[:text, 'and underlined'],
			[:closing_tag, '[/u]'],
			[:text, ' in some places'],
			[:closing_tag, '[/b]'],
			[:text, ', and in some places not']
		])
		
		maker = RbbCode::HtmlMaker.new

		maker.make_html(input).should == 'This <strong>text is bold <u>and underlined</u> in some places</strong>, and in some places not'
	end
	
	it 'should corrrectly replace img' do
		input = make_tokens([
			[:opening_tag, '[img]'],
			[:text, 'http://example.com/image.jpg'],
			[:closing_tag, '[/img]']
		])
		
		maker = RbbCode::HtmlMaker.new
		
		maker.make_html(input).should == '<img src="http://example.com/image.jpg" alt=""/>'
	end
	
	it 'should correctly replace url with no value' do
		input = make_tokens([
			[:opening_tag, '[url]'],
			[:text, 'http://example.com'],
			[:closing_tag, '[/url]']
		])
		
		maker = RbbCode::HtmlMaker.new
		
		maker.make_html(input).should == '<a href="http://example.com">http://example.com</a>'
	end
	
	it 'should correctly replace url with a value' do
		input = make_tokens([
			[:opening_tag, '[url=http://example.com]'],
			[:text, 'Example'],
			[:closing_tag, '[/url]']
		])
		
		maker = RbbCode::HtmlMaker.new
		
		maker.make_html(input).should == '<a href="http://example.com">Example</a>'
	end
	
	it 'should not allow JavaScript in the tag values' do
		input = make_tokens([
			[:opening_tag, '[url=javascript://%0ASh=alert(%22Foo%22);window.close();]'],
			[:text, 'Foo Alert'],
			[:closing_tag, '[/url]']
		])
		
		maker = RbbCode::HtmlMaker.new
		
		maker.make_html(input).should == '<a href="#js_not_allowed">Foo Alert</a>'
	end
end