require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/node_spec_helper')
require 'pp'

describe RbbCode::TreeMaker do
	include NodeMatchers
	
	context '#make_tree' do
		def expect_tree(str, &block)
			expected = NodeBuilder.build(&block)
			@tree_maker.make_tree(str).should match_node(expected)
		end
		
		before :each do
			@schema = RbbCode::Schema.new
			@tree_maker = RbbCode::TreeMaker.new(@schema)
		end		

		it 'should make a tree from a string with one tag' do
			str = 'This is [b]bold[/b] text'
			
			expect_tree(str) do
				tag('p') do
					text 'This is '
					tag('b') { text 'bold' }
					text ' text'
				end
			end
		end
	
		it 'should ignore tags that are invalid in their context' do
			@schema.tag('u').may_not_descend_from('b')
			
			str = 'This is [b]bold and [u]underlined[/u][/b] text'
			
			expect_tree(str) do
				tag('p') do
					text 'This is '
					tag('b') do
						text 'bold and '
						text 'underlined'
					end
					text ' text'
				end
			end
		end

		it 'should create paragraph tags' do
			str = "This is a paragraph.\n\nThis is another."
			
			expect_tree(str) do
				tag('p') do
					text 'This is a paragraph.'
				end
				tag('p') do
					text 'This is another.'
				end
			end
		end

		it 'should not put block-level elements inside paragraph tags' do
			str = "This is a list:\n\n[list]\n\n[*]Foo[/i]\n\n[/list]\n\nwith some text after it"
			
			expect_tree(str) do
				tag('p') do
					text 'This is a list:'
				end
				tag('list') do
					tag('*') { text 'Foo' }
				end
				tag('p') do
					text 'with some text after it'
				end
			end
		end
		
		it 'should not insert br tags in the midst of block-level elements' do
			str = "List:\n[list]\n[*]Foo[/*]\n[*]Bar[/*]\n[/list]\nText after list"
			
			expect_tree(str) do
				tag('p') do
					text 'List:'
				end
				tag('list') do
					tag('*') { text 'Foo' }
					tag('*') { text 'Bar' }
				end
				tag('p') do
					text 'Text after list'
				end
			end
		end
		
		it 'should store tag values' do
			str = 'This is a [url=http://google.com]link[/url]'
			
			expect_tree(str) do
				tag('p') do
					text 'This is a '
					tag('url', 'http://google.com') do
						text 'link'
					end
				end
			end
		end
	end
end