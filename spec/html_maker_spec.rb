require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/node_spec_helper')

describe RbbCode::HtmlMaker do
	context '#make_html' do
		def expect_html(expected_html, &block)
			@html_maker.make_html(NodeBuilder.build(&block)).should == expected_html
		end
		
		before :each do
			@html_maker = RbbCode::HtmlMaker.new
		end
		
		it 'should replace simple BB code tags with HTML tags' do
			expect_html('<p>This is <strong>bold</strong> text</p>') do
				tag('p') do
					text 'This is '
					tag('b') { text 'bold' }
					text ' text'
				end
			end
		end
	end
end