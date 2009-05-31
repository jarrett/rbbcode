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
		
		it 'should work for nested tags' do
			expect_html('<p>This is <strong>bold and <u>underlined</u></strong> text</p>') do
				tag('p') do
					text 'This is '
					tag('b') do
						text 'bold and '
						tag('u') { text 'underlined' }
					end
					text ' text'
				end
			end
		end

		it 'should not allow JavaScript in URLs' do
			urls = {
				'javascript:alert("foo");' => 'http://javascript%3Aalert("foo");',
				'j a v a script:alert("foo");' => 'http://j+a+v+a+script%3Aalert("foo");',
				' javascript:alert("foo");' => 'http://+javascript%3Aalert("foo");',
				'JavaScript:alert("foo");' => 'http://JavaScript%3Aalert("foo");' ,
				"java\nscript:alert(\"foo\");" => 'http://java%0Ascript%3Aalert("foo");',
				"java\rscript:alert(\"foo\");" => 'http://java%0Dscript%3Aalert("foo");'
			}
			
			# url tag
			urls.each do |evil_url, clean_url|
				expect_html("<p><a href=\"#{clean_url}\">foo</a></p>") do
					tag('p') do
						tag('url', evil_url) do
							text 'foo'
						end
					end
				end
			end
			
			# img tag
			urls.each do |evil_url, clean_url|
				expect_html("<p><img src=\"#{clean_url}\" alt=\"\"/></p>") do
					tag('p') do
						tag('img') do
							text evil_url
						end
					end
				end
			end
		end
	end
end