require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RbbCode::Cleaner do
	include TokenTestHelper
	
	it 'should close unclosed opening tags' do
		input = make_tokens([
			[:text, 'This '],
			[:opening_tag, '[b]'],
			[:text, 'is unmatched, but this '],
			[:opening_tag, '[i]'],
			[:text, 'is not'],
			[:closing_tag, '[/i]']
		])
		
		cleaner = RbbCode::Cleaner.new(input, RbbCode::Schema.new)
		cleaned = cleaner.clean
		
		cleaned.length.should == 7
		
		cleaned[0].type.should == :text
		cleaned[0].text.should == 'This '
		
		cleaned[1].type.should == :opening_tag
		cleaned[1].tag_name.should == 'b'
		
		cleaned[2].type.should == :text
		cleaned[2].text.should == 'is unmatched, but this '
		
		cleaned[3].type.should == :opening_tag
		cleaned[3].tag_name.should == 'i'
		
		cleaned[4].type.should == :text
		cleaned[4].text.should == 'is not'
		
		cleaned[5].type.should == :closing_tag
		cleaned[5].tag_name.should == 'i'
		
		cleaned[6].type.should == :closing_tag
		cleaned[6].tag_name.should == 'b'
		
		cleaner.errors?.should == true
	end
	
	it 'should remove unmatched closing tags' do
		input = make_tokens([
			[:text, 'This '],
			[:closing_tag, '[/i]'],
			[:text, ' tag is unmatched']
		])
		
		cleaner = RbbCode::Cleaner.new(input, RbbCode::Schema.new)
		cleaned = cleaner.clean
		
		cleaned.length.should == 2
		
		cleaned[0].type.should == :text
		cleaned[0].text.should == 'This '
		
		cleaned[1].type.should == :text
		cleaned[1].text.should == ' tag is unmatched'
		
		cleaner.errors?.should == true
	end
	
	it 'should switch the order of mismatched tags' do
		input = make_tokens([
			[:opening_tag, '[b]'],
			[:text, 'bold '],
			[:opening_tag, '[i]'],
			[:text, 'italic'],
			[:closing_tag, '[/b]'],
			[:closing_tag, '[/i]'],
			[:text, ' mismatch']
		])
		
		cleaner = RbbCode::Cleaner.new(input, RbbCode::Schema.new)
		cleaned = cleaner.clean
		
		cleaned.length.should == 7
		
		cleaned[0].type.should == :opening_tag
		cleaned[0].tag_name.should == 'b'
		
		cleaned[1].type.should == :text
		cleaned[1].text.should == 'bold '
		
		cleaned[2].type.should == :opening_tag
		cleaned[2].tag_name.should == 'i'
		
		cleaned[3].type.should == :text
		cleaned[3].text.should == 'italic'
		
		cleaned[4].type.should == :closing_tag
		cleaned[4].tag_name.should == 'i'
		
		cleaned[5].type.should == :closing_tag
		cleaned[5].tag_name.should == 'b'
		
		cleaned[6].type.should == :text
		cleaned[6].text.should == ' mismatch'
		
		cleaner.errors?.should == true
	end
	
	it 'should properly mate nested tags' do
		'[quote]Foo said [quote]bar[/quote][/quote]'
		input = make_tokens([
			[:opening_tag, '[quote]'],
			[:text, 'Foo said '],
			[:opening_tag, '[quote]'],
			[:text, 'bar'],
			[:closing_tag, '[/quote]'],
			[:closing_tag, '[/quote]']
		])
		
		cleaner = RbbCode::Cleaner.new(input, RbbCode::Schema.new)
		cleaned = cleaner.clean
		
		cleaned.length.should == 6
		
		cleaned[0].type.should == :opening_tag
		cleaned[0].tag_name.should == 'quote'
		cleaned[0].mate.should == cleaned[5]
		
		cleaned[1].type.should == :text
		cleaned[1].text.should == 'Foo said '
		
		cleaned[2].type.should == :opening_tag
		cleaned[2].tag_name.should == 'quote'
		cleaned[2].mate.should == cleaned[4]
		
		cleaned[3].type.should == :text
		cleaned[3].text.should == 'bar'
		
		cleaned[4].type.should == :closing_tag
		cleaned[4].tag_name.should == 'quote'
		cleaned[4].mate.should == cleaned[2]
		
		cleaned[5].type.should == :closing_tag
		cleaned[5].tag_name.should == 'quote'
		cleaned[5].mate.should == cleaned[0]
		
		cleaner.errors?.should == false
	end
	
	it 'should not change a valid set of tokens' do
		input = make_tokens([
			[:text, 'This is '],
			[:opening_tag, '[b]'],
			[:text, 'bold'],
			[:closing_tag, '[/b]'],
			[:text, ' text']
		])
		
		cleaner = RbbCode::Cleaner.new(input, RbbCode::Schema.new)		
		cleaned = cleaner.clean
		
		cleaned.length.should == 5
		
		cleaned[0].type.should == :text
		cleaned[0].text.should == 'This is '
		
		cleaned[1].type.should == :opening_tag
		cleaned[1].tag_name.should == 'b'
		
		cleaned[2].type.should == :text
		cleaned[2].text.should == 'bold'
		
		cleaned[3].type.should == :closing_tag
		cleaned[3].tag_name.should == 'b'
		
		cleaned[4].type.should == :text
		cleaned[4].text.should == ' text'
		
		cleaner.errors?.should == false
	end
	
	it 'should remove tags that are not allowed' do
		input = make_tokens([
			[:text, 'There is '],
			[:opening_tag, '[foo]'],
			[:text, 'no such thing'],
			[:closing_tag, '[/foo]'],
			[:text, ' as a foo tag']
		])
		
		cleaner = RbbCode::Cleaner.new(input, RbbCode::Schema.new)		
		cleaned = cleaner.clean
		
		cleaned.length.should == 3
		
		cleaned[0].type.should == :text
		cleaned[0].text.should == 'There is '
		
		cleaned[1].type.should == :text
		cleaned[1].text.should == 'no such thing'
		
		cleaned[2].type.should == :text
		cleaned[2].text.should == ' as a foo tag'
	end
	
	it 'should remove tags that are allowed in general, but not in their context' do
		input = make_tokens([
			[:opening_tag, '[b]'],
			[:text, 'Bold and '],
			[:opening_tag, '[b]'],
			[:text, 'bolder'],
			[:closing_tag, '[/b]'],
			[:text, ' still'],
			[:closing_tag, '[/b]']
		])
		
		schema = RbbCode::Schema.new
		schema.tag('b').may_not_be_nested
		cleaner = RbbCode::Cleaner.new(input, schema)
		cleaned = cleaner.clean
		
		cleaned.length.should == 5
		
		cleaned[0].type.should == :opening_tag
		cleaned[0].tag_name.should == 'b'
		
		cleaned[1].type.should == :text
		cleaned[1].text.should == 'Bold and '
		
		cleaned[2].type.should == :text
		cleaned[2].text.should == 'bolder'
		
		cleaned[3].type.should == :text
		cleaned[3].text.should == ' still'
		
		cleaned[4].type.should == :closing_tag
		cleaned[4].tag_name.should == 'b'
	end
end