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
		
		expected = make_tokens([
			[:text, 'This '],
			[:text, 'is unmatched, but this '],
			[:opening_tag, '[i]'],
			[:text, 'is not'],
			[:closing_tag, '[/i]']
		])
		
		cleaned = RbbCode::Cleaner.new(@tokens).clean
		cleaned.should == expected
	end
	
	it 'should remove unmatched closing tags' do
		input = make_tokens([
			[:text, 'This '],
			[:closing_tag, '[/i]'],
			[:text, ' tag is unmatched']
		])
		
		expected = make_tokens([
			[:text, 'This '],
			[:text, ' tag is unmatched']
		])
		
		cleaned = RbbCode::Cleaner.new(@tokens).clean
		cleaned.should == expected
	end
end