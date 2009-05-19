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
		
		maker = RbbCode::HtmlMaker.new(input)
		
		maker.make_html.should == 'This is <strong>bold</strong> text'
	end
	
	it 'should corrrectly replace img' do
		raise 'not implemented'
	end
	
	it 'should correctly replace url' do
		raise 'not implemented'
	end
end