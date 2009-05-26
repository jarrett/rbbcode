require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RbbCode::LineBreaker do
	context 'break_lines' do
		before :each do
			@line_breaker = RbbCode::LineBreaker.new
		end
		
		it 'should add [p] to the beginning' do
			input = 'This is [b]bold[/b] text'
			@line_breaker.break_lines(input)[0,3].should == '[p]'
		end
		
		it 'should add [/p] to the end' do
			input = 'This is [b]bold[/b] text'
			@line_breaker.break_lines(input)[-4..-1].should == '[/p]'
		end
		
		it 'should replace "\n\n" with "[/p][p]"' do
			input = "foo\n\nbar"
			@line_breaker.break_lines(input).should == '[p]foo[/p][p]bar[/p]'
		end
		
		it 'should replace "\r\n\r\n" with "[/p][p]"' do
			input = "foo\r\n\r\nbar"
			@line_breaker.break_lines(input).should == '[p]foo[/p][p]bar[/p]'
		end
		
		it 'should replace "\r\r" with "[/p][p]"' do
			input = "foo\r\rbar"
			@line_breaker.break_lines(input).should == '[p]foo[/p][p]bar[/p]'
		end
		
		it 'should replace "\n" with "[br][/br]"' do
			input = "foo\nbar"
			@line_breaker.break_lines(input).should == '[p]foo[br][/br]bar[/p]'
		end
		
		it 'should replace "\r" with "[br][/br]"' do
			input = "foo\rbar"
			@line_breaker.break_lines(input).should == '[p]foo[br][/br]bar[/p]'
		end
		
		it 'should replace "\r\n" with "[br][/br]"' do
			input = "foo\r\nbar"
			@line_breaker.break_lines(input).should == '[p]foo[br][/br]bar[/p]'
		end
		
		it 'should replace "\r\n\r" with "[p][/p]"' do
			input = "foo\r\n\rbar"
			@line_breaker.break_lines(input).should == '[p]foo[/p][p]bar[/p]'
		end
		
		it 'should replace "\r\n\n" with "[p][/p]"' do
			input = "foo\r\n\nbar"
			@line_breaker.break_lines(input).should == '[p]foo[/p][p]bar[/p]'
		end
	end
end