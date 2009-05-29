require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/tree_maker_spec_helper')
require 'pp'

describe RbbCode::TreeMaker do
	include TreeMakerMatchers
	
	context '#make_tree' do
		before :each do
			@schema = RbbCode::Schema.new
		end
		
		it 'should make a tree from a string with one tag' do
			str = 'This is [b]bold[/bold] text'
			
			expected = ExpectedTreeMaker.make do
				text 'This is '
				tag('b') { text 'bold' }
				text ' text'
				text ' foo'
			end
			
			RbbCode::TreeMaker.new(@schema).make_tree(str).should match_tree(expected)
		end
		
		it 'should ignore tags that are invalid in their context' do
		end
	end
end