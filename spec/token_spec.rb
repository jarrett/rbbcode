require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RbbCode::Token do
	context 'has_value?' do
		it 'should return true if there is an =' do
			token = RbbCode::Token.new(:opening_tag)
			token.text = '[url=http://example.com]'
			token.has_value?.should == true
		end
		
		it 'should return false if there is not an =' do
			token = RbbCode::Token.new(:opening_tag)
			token.text = '[url]'
			token.has_value?.should == false
		end
		
		it 'should raise if it\'s called on anything other than an opening tag' do
			[
				[:unknown, ''],
				[:text, 'foo'],
				[:closing_tag, '[/foo]']
			].each do |type, text|
				token = RbbCode::Token.new(type)
				token.text = text
				lambda { token.has_value? }.should raise_error(RbbCode::TokenTypeError)
			end
		end
	end
	
	context 'tag_name' do
		it 'should find the tag name in an opening tag without a value' do
			token = RbbCode::Token.new(:opening_tag)
			token.text = '[url]'
			token.tag_name.should == 'url'
		end
		
		it 'should find the tag name in an opening tag with a value' do
			token = RbbCode::Token.new(:opening_tag)
			token.text = '[url=http://example.com]'
			token.tag_name.should == 'url'
		end
		
		it 'should find the tag name in a closing tag' do
			token = RbbCode::Token.new(:closing_tag)
			token.text = '[/url]'
			token.tag_name.should == 'url'
		end
		
		it 'should raise if it\'s called on anything other than an opening tag or a closing tag' do
			[
				[:unknown, ''],
				[:text, 'foo'],
				[:possible_tag, '[']
			].each do |type, text|
				token = RbbCode::Token.new(type)
				token.text = text
				lambda { token.has_value? }.should raise_error(RbbCode::TokenTypeError)
			end
		end
	end
	
	context 'tag_name=' do
		it 'should set the tag name for a closing tag' do
			token = RbbCode::Token.new(:closing_tag)
			token.tag_name = 'b'
			token.tag_name.should == 'b'
			token.text.should == '[/b]'
		end
		
		it 'should set the tag name for an opening tag without a value' do
			token = RbbCode::Token.new(:opening_tag)
			token.tag_name = 'b'
			token.tag_name.should == 'b'
			token.text.should == '[b]'
		end
		
		it 'should set the tag name for an opening tag with a value' do
			token = RbbCode::Token.new(:opening_tag)
			token.text = '[url=http://example.com]'
			token.tag_name = 'b'
			token.tag_name.should == 'b'
			token.text.should == '[b=http://example.com]'			
		end
	end
	
	context 'value' do
		it 'should return the value of a url tag' do
			token = RbbCode::Token.new(:opening_tag)
			token.text = '[url=http://example.com]'
			token.value.should == 'http://example.com'
		end
		
		it 'should return nil for a tag without a value' do
			token = RbbCode::Token.new(:opening_tag)
			token.text = '[url]'
			token.value.should == nil
		end
	end
end