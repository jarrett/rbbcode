require File.expand_path(File.dirname(__FILE__) + '/../lib/rbbcode')

describe RbbCode::Tokenizer do
	it 'should tokenize "This is a [b]bold[/b] string"' do
		str = 'This is a [b]bold[/b] string'
		puts str
		tokens = RbbCode::Tokenizer.new(str).tokenize
		puts tokens.collect { |token| [token.type, token.text] }.inspect
		
		tokens.length.should == 5
		
		tokens[0].type.should == :text
		tokens[0].text.should == 'This is a '
		
		tokens[1].type.should == :opening_tag
		tokens[1].text.should == '[b]'
		tokens[1].tag_name.should == 'b'
		
		tokens[2].type.should == :text
		tokens[2].text.should == 'bold'
		
		tokens[3].type.should == :closing_tag
		tokens[3].text.should == '[/b]'
		tokens[3].tag_name.should == 'b'
		
		tokens[4].type.should == :text
		tokens[4].text.should == ' string'
	end
	
	it 'should tokenize "This is [[b]improperly[/b] formed"' do
		str = 'This is [[b]improperly[/b] formed'
		puts str
		tokens = RbbCode::Tokenizer.new(str).tokenize
		puts tokens.collect { |token| [token.type, token.text] }.inspect
		
		tokens.length.should == 5
		
		tokens[0].type.should == :text
		tokens[0].text.should == 'This is ['
		
		tokens[1].type.should == :opening_tag
		tokens[1].text.should == '[b]'
		tokens[1].tag_name.should == 'b'
		
		tokens[2].type.should == :text
		tokens[2].text.should == 'improperly'
		
		tokens[3].type.should == :closing_tag
		tokens[3].text.should == '[/b]'
		tokens[3].tag_name.should == 'b'
		
		tokens[4].type.should == :text
		tokens[4].text.should == ' formed'
	end
	
	it 'should tokenize "This is [b]]improperly[/b] formed"' do
		str = 'This is [b]]improperly[/b] formed'
		puts str
		tokens = RbbCode::Tokenizer.new(str).tokenize
		puts tokens.collect { |token| [token.type, token.text] }.inspect
		
		tokens.length.should == 5
		
		tokens[0].type.should == :text
		tokens[0].text.should == 'This is '
		
		tokens[1].type.should == :opening_tag
		tokens[1].text.should == '[b]'
		
		tokens[2].type.should == :text
		tokens[2].text.should == ']improperly'
		
		tokens[3].type.should == :closing_tag
		tokens[3].text.should == '[/b]'
		tokens[3].tag_name.should == 'b'
		
		tokens[4].type.should == :text
		tokens[4].text.should == ' formed'
	end
	
	it 'should tokenize "This is [b]improperly[[/b] formed"' do
		str = 'This is [b]improperly[[/b] formed'
		puts str
		tokens = RbbCode::Tokenizer.new(str).tokenize
		puts tokens.collect { |token| [token.type, token.text] }.inspect
		
		tokens.length.should == 5
		
		tokens[0].type.should == :text
		tokens[0].text.should == 'This is '
		
		tokens[1].type.should == :opening_tag
		tokens[1].text.should == '[b]'
		tokens[1].tag_name.should == 'b'
		
		tokens[2].type.should == :text
		tokens[2].text.should == 'improperly['
		
		tokens[3].type.should == :closing_tag
		tokens[3].text.should == '[/b]'
		tokens[3].tag_name.should == 'b'
		
		tokens[4].type.should == :text
		tokens[4].text.should == ' formed'
	end
	
	it 'should tokenize "This is [b]improperly[/b]] formed"' do
		str = 'This is [b]improperly[/b]] formed'
		puts str
		tokens = RbbCode::Tokenizer.new(str).tokenize
		puts tokens.collect { |token| [token.type, token.text] }.inspect
		
		tokens.length.should == 5
		
		tokens[0].type.should == :text
		tokens[0].text.should == 'This is '
		
		tokens[1].type.should == :opening_tag
		tokens[1].text.should == '[b]'
		tokens[1].tag_name.should == 'b'
		
		tokens[2].type.should == :text
		tokens[2].text.should == 'improperly'
		
		tokens[3].type.should == :closing_tag
		tokens[3].text.should == '[/b]'
		
		tokens[4].type.should == :text
		tokens[4].text.should == '] formed'
	end
	
	it 'should tokenize "This is [b][improperly[/b] formed"' do
		str = 'This is [b][improperly[/b] formed'
		puts str
		tokens = RbbCode::Tokenizer.new(str).tokenize
		puts tokens.collect { |token| [token.type, token.text] }.inspect
		
		tokens.length.should == 5
		
		tokens[0].type.should == :text
		tokens[0].text.should == 'This is '
		
		tokens[1].type.should == :opening_tag
		tokens[1].text.should == '[b]'
		tokens[1].tag_name.should == 'b'
		
		tokens[2].type.should == :text
		tokens[2].text.should == '[improperly'
		
		tokens[3].type.should == :closing_tag
		tokens[3].text.should == '[/b]'
		
		tokens[4].type.should == :text
		tokens[4].text.should == ' formed'
	end
	
	it 'should tokenize "This is [b]improperly[/b][ formed"' do
		str = 'This is [b]improperly[/b][ formed'
		puts str
		tokens = RbbCode::Tokenizer.new(str).tokenize
		puts tokens.collect { |token| [token.type, token.text] }.inspect
		
		tokens.length.should == 5
		
		tokens[0].type.should == :text
		tokens[0].text.should == 'This is '
		
		tokens[1].type.should == :opening_tag
		tokens[1].text.should == '[b]'
		tokens[1].tag_name.should == 'b'
		
		tokens[2].type.should == :text
		tokens[2].text.should == 'improperly'
		
		tokens[3].type.should == :closing_tag
		tokens[3].text.should == '[/b]'
		
		tokens[4].type.should == :text
		tokens[4].text.should == '[ formed'
	end
	
	it 'should tokenize "This here [ is a lone bracket' do
		str = 'This here [ is a lone bracket'
		puts str
		tokens = RbbCode::Tokenizer.new(str).tokenize
		puts tokens.collect { |token| [token.type, token.text] }.inspect
		
		tokens.length.should == 1
		
		tokens[0].type.should == :text
		tokens[0].text.should == str
	end
	
	it 'should not differentiate between valid and invalid tags' do
		str = 'This is an [foo]unrecognized[/foo] tag'
		
		tokens = RbbCode::Tokenizer.new(str).tokenize
		puts tokens.collect { |token| [token.type, token.text] }.inspect
		
		tokens.length.should == 5
		
		tokens[0].type.should == :text
		tokens[0].text.should == 'This is an '
		
		tokens[1].type.should == :opening_tag
		tokens[1].text.should == '[foo]'
		tokens[1].tag_name.should == 'foo'
		
		tokens[2].type.should == :text
		tokens[2].text.should == 'unrecognized'
		
		tokens[3].type.should == :closing_tag
		tokens[3].text.should == '[/foo]'
		tokens[3].tag_name.should == 'foo'
		
		tokens[4].type.should == :text
		tokens[4].text.should == ' tag'
	end
end