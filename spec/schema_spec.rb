require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RbbCode::Schema do
	before :each do
		@schema = RbbCode::Schema.new
		@schema.clear
		@schema.allow_tags(*RbbCode::DEFAULT_ALLOWED_TAGS)
	end
	
	it 'should allow the default tags at the top level' do
		schema = RbbCode::Schema.new
		[
			'b',
			'i',
			'u',
			'url',
			'img',
			'code',
			'quote',
			'list'
		].each do |tag|
			schema.tag(tag).valid_in_context?().should == true
		end
	end
	
	it 'should not allow unknown tags' do
		@schema.tag('foo').valid_in_context?().should == false
	end
	
	it 'should return a new SchemaTag object when tag is called' do
		@schema.tag('b').should be_a(RbbCode::SchemaTag)
	end
	
	it 'should not allow nesting a tag when may_not_be_nested is called on it' do
		@schema.tag('b').may_not_be_nested
		@schema.tag('b').valid_in_context?('b').should == false
	end
	
	it 'should allow nesting a tag when may_be_nested is called on it' do
		@schema.tag('b').may_not_be_nested
		@schema.tag('b').may_be_nested
		@schema.tag('b').valid_in_context?('b').should == true
	end
	
	it 'should not allow a tag to descend from another when forbidden by may_not_descend_from' do
		@schema.tag('b').may_not_descend_from('u')
		@schema.tag('b').valid_in_context?('u').should == false
	end
	
	it 'should allow a tag to descend from another when permitted by may_descend_from' do
		@schema.tag('b').may_not_descend_from('u')
		@schema.tag('b').may_descend_from('u')
		@schema.tag('b').valid_in_context?('u').should == true
	end
	
	it 'should not allow a tag to descend from anything other than the tags specified in must_be_child_of' do
		@schema.tag('b').must_be_child_of('u', 'quote')
		@schema.tag('b').valid_in_context?('i').should == false
		@schema.tag('b').valid_in_context?('u').should == true
		@schema.tag('b').valid_in_context?('quote').should == true
	end
	
	it 'should allow a tag to descend from the one specified in must_be_child_of' do
		@schema.tag('b').may_not_descend_from('u')
		@schema.tag('b').must_be_child_of('u')
		@schema.tag('b').valid_in_context?('u').should == true
	end
	
	it 'should not require a tag to be a child of another when need_not_be_child_of is called' do
		@schema.tag('b').must_be_child_of('u')
		@schema.tag('b').need_not_be_child_of('u')
		@schema.tag('b').valid_in_context?('i').should == true
	end
	
	it 'should allow only the specified tag as a child when may_only_be_parent_of is called' do
		@schema.tag('list').may_only_be_parent_of('*')
		@schema.tag('*').valid_in_context?('list').should == true
		@schema.tag('u').valid_in_context?('list').should == false
		@schema.tag('u').valid_in_context?('*', 'list').should == true
	end
	
	it 'should not allow text inside a tag when may_not_contain_text is called' do
		@schema.tag('list').may_not_contain_text
		@schema.text.valid_in_context?('list').should == false
	end
	
	it 'should allow text inside a tag when may_contain_text is called' do
		@schema.tag('list').may_not_contain_text
		@schema.tag('list').may_contain_text
		@schema.text.valid_in_context?('list').should == true
	end
	
	it 'should not allow text or children when must_be_empty is called' do
		@schema.tag('br').must_be_empty
		@schema.text.valid_in_context?('br').should == false
		@schema.tag('b').valid_in_context?('br').should == false
	end
end