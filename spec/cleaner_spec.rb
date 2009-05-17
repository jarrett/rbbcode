require File.expand_path(File.dirname(__FILE__) + '/../lib/rbbcode')

describe RbbCode::Cleaner do
	def make_tokens(tuples)
		tuples.collect do |tuple|
			token = RbbCode::Token.new(tuple[0])
			token.text = tuple[1]
			token
		end
	end
	
	it 'should remove unmatched opening tags' do
		input = make_tokens([
			[:text, 'This '],
			[:opening_tag, '[b]'],
			[:text, 'is unmatched, but this '],
			[:opening_tag, '[i]'],
			[:text, 'is not'],
			[:closing_tag, '[/i]']
		])
		
		cleaned = RbbCode::Cleaner.new(input).clean
		
		cleaned.length.should == 5
		
		cleaned[0].type.should == :text
		cleaned[0].text.should == 'This '
		
		cleaned[1].type.should == :text
		cleaned[1].text.should == 'is unmatched, but this '
		
		cleaned[2].type.should == :opening_tag
		cleaned[2].tag_name.should == 'i'
		
		cleaned[3].type.should == :text
		cleaned[3].text.should == 'is not'
		
		cleaned[4].type.should == :closing_tag
		cleaned[4].tag_name.should == 'i'
	end
	
	it 'should remove unmatched closing tags' do
		input = make_tokens([
			[:text, 'This '],
			[:closing_tag, '[/i]'],
			[:text, ' tag is unmatched']
		])
		
		cleaned = RbbCode::Cleaner.new(input).clean
		
		cleaned.length.should == 2
		
		cleaned[0].type.should == :text
		cleaned[0].text.should == 'This '
		
		cleaned[1].type.should == :text
		cleaned[1].text.should == ' tag is unmatched'
	end
	
	it 'should not change a valid set of tokens' do
		input = make_tokens([
			[:text, 'This is '],
			[:opening_tag, '[b]'],
			[:text, 'bold'],
			[:closing_tag, '[/b]'],
			[:text, ' text']
		])
		
		cleaned = RbbCode::Cleaner.new(input).clean
		
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
	end
	
	context 'errors?' do
		it 'should return false if nothing was removed' do
			input = make_tokens([
			[:text, 'This is '],
			[:opening_tag, '[b]'],
				[:text, 'bold'],
				[:closing_tag, '[/b]'],
				[:text, ' text']
			])
			
			cleaner = RbbCode::Cleaner.new(input)
			cleaner.clean
			cleaner.errors?.should == false
		end
		
		it 'should return true if anything was removed' do
			input = make_tokens([
				[:text, 'This '],
				[:opening_tag, '[b]'],
				[:text, 'is unmatched, but this '],
				[:opening_tag, '[i]'],
				[:text, 'is not'],
				[:closing_tag, '[/i]']
			])
			
			cleaner = RbbCode::Cleaner.new(input)
			cleaner.clean
			cleaner.errors?.should == true
		end
	end
end