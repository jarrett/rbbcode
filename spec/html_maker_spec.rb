# encoding: UTF-8

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
			urls = [
				'javascript:alert("1");',
				'j a v a script:alert("2");',
				' javascript:alert("3");',
				'JavaScript:alert("4");',
				"java\nscript:alert(\"5\");",
				"java\rscript:alert(\"6\");"
			]
			
			# url tag
			urls.each do |evil_url|
				expect_html('<p><a href="">foo</a></p>') do
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
		
		it 'should hex-encode double-quotes in the URL' do
			expect_html('<p><a href="http://example.com/foo%22bar">Foo</a></p>') do
				tag('p') do
					tag('url', 'http://example.com/foo"bar') do
						text 'Foo'
					end
				end
			end
		end
		
		it 'wraps preformatted tags in <pre>' do
			expect_html('<p><pre><code>Some code</code></pre></p>') do
				tag('p') do
					tag('code', nil, true) do
						text 'Some code'
					end
				end
			end
		end
	end	
end