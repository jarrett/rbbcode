module RbbCode
	DEFAULT_ALLOWED_TAGS = [
		'p',
		'br',
		'b',
		'i',
		'u',
		'url',
		'img',
		'code',
		'quote',
		'list',
		'*'
	]
	
	DEFAULT_BLOCK_LEVEL_ELEMENTS = [
		'quote',
		'list',
		'*'
	]
	
	class SchemaNode
		def initialize(schema)
			@schema = schema
		end
		
		protected
		
		def normalize_ancestors(ancestors)
			if ancestors.length == 1 and ancestors[0].is_a?(Array)
				ancestors = ancestors[0]
			end
			ancestors
		end
	end
	
	class SchemaTag < SchemaNode
		def initialize(schema, name)
			@schema = schema
			@name = name
		end
		
		def may_be_nested
			@schema.allow_descent(@name, @name)
			self
		end
		
		def may_contain_text
			@schema.allow_text(@name)
			self
		end
		
		def may_not_be_nested
			@schema.forbid_descent(@name, @name)
			self
		end
		
		def may_descend_from(tag_name)
			@schema.allow_descent(tag_name, @name)
			self
		end
		
		def may_only_be_parent_of(*tag_names)
			@schema.forbid_children_except(@name, *tag_names)
			self
		end
		
		def may_not_contain_text
			@schema.forbid_text(@name)
			self
		end
		
		def may_not_descend_from(tag_name)
			@schema.forbid_descent(tag_name, @name)
			self
		end
		
		def must_be_child_of(*tag_names)
			@schema.require_parents(tag_names, @name)
			self
		end
		
		def must_be_empty
			@schema.forbid_children_except(@name, [])
			may_not_contain_text
			self
		end
		
		def need_not_be_child_of(tag_name)
			@schema.unrequire_parent(tag_name, @name)
			self
		end
		
		# Returns true if tag_name is valid in the context defined by its list of ancestors.
		# ancestors should be ordered from most recent ancestor to most distant.
		def valid_in_context?(*ancestors)
			@schema.tag_valid_in_context?(@name, normalize_ancestors(ancestors))
		end
	end
	
	class SchemaText < SchemaNode
		def valid_in_context?(*ancestors)
			@schema.text_valid_in_context?(normalize_ancestors(ancestors))
		end
	end

	class Schema
		def allow_descent(ancestor, descendant) #:nodoc:
			if @forbidden_descent.has_key?(descendant.to_s) and @forbidden_descent[descendant.to_s].include?(ancestor.to_s)
				@forbidden_descent[descendant.to_s].delete(ancestor.to_s)
			end
		end
		
		def allow_tag(*tag_names)
			tag_names.each do |tag_name|
				unless @allowed_tags.include?(tag_name.to_s)
					@allowed_tags << tag_name.to_s
				end
			end
		end
		
		def allow_text(tag_name)
			@no_text.delete(tag_name.to_s)
		end
		
		def block_level?(tag_name)
			DEFAULT_BLOCK_LEVEL_ELEMENTS.include?(tag_name.to_s)
		end
		
		alias_method :allow_tags, :allow_tag
		
		def clear
			@allowed_tags = []
			@forbidden_descent = {}
			@required_parents = {}
			@no_text = []
		end
		
		def forbid_children_except(parent, children)
			@child_requirements[parent.to_s] = children.collect { |c| c.to_s }
		end
		
		def forbid_descent(ancestor, descendant) #:nodoc:
			@forbidden_descent[descendant.to_s] ||= []
			unless @forbidden_descent[descendant.to_s].include?(ancestor.to_s)
				@forbidden_descent[descendant.to_s] << ancestor.to_s
			end
		end
		
		def forbid_tag(name)
			@allowed_tags.delete(name.to_s)
		end
		
		def forbid_text(tag_name)
			@no_text << tag_name.to_s unless @no_text.include?(tag_name.to_s)
		end
		
		def initialize
			@allowed_tags = DEFAULT_ALLOWED_TAGS.dup
			@forbidden_descent = {}
			@required_parents = {}
			@child_requirements = {}
			@no_text = []
			use_defaults
		end
		
		def line_break_tag_name
			'br'
		end
		
		def paragraph_tag_name
			'p'
		end
		
		def require_parents(parents, child) #:nodoc:
			@required_parents[child.to_s] = parents.collect { |p| p.to_s }
			parents.each do |parent|
				if @forbidden_descent.has_key?(child.to_s)
					@forbidden_descent[child.to_s].delete(parent)
				end
			end
		end
		
		def tag(name)
			SchemaTag.new(self, name)
		end
		
		def tag_valid_in_context?(tag_name, ancestors)
			return false unless @allowed_tags.include?(tag_name.to_s)
			if @required_parents.has_key?(tag_name.to_s) and !@required_parents[tag_name.to_s].include?(ancestors[0].to_s)
				return false
			end
			if @child_requirements.has_key?(ancestors[0].to_s) and !@child_requirements[ancestors[0].to_s].include?(tag_name.to_s)
				return false
			end
			if @forbidden_descent.has_key?(tag_name.to_s)
				@forbidden_descent[tag_name.to_s].each do |forbidden_ancestor|
					return false if ancestors.include?(forbidden_ancestor)
				end
			end
			return true
		end
		
		def text
			SchemaText.new(self)
		end
		
		def text_valid_in_context?(*ancestors)
			if @no_text.include?(ancestors[0].to_s)
				return false
			end
			return true
		end

		def unrequire_parent(parent, child)
			@required_parents.delete(child.to_s)
		end
		
		def use_defaults
			tag('br').must_be_empty
			tag('p').may_not_be_nested
			tag('b').may_not_be_nested
			tag('i').may_not_be_nested
			tag('u').may_not_be_nested
			tag('url').may_not_be_nested
			tag('img').may_not_be_nested
			tag('code').may_not_be_nested
			tag('p').may_not_be_nested
			tag('*').must_be_child_of('list')
			tag('list').may_not_descend_from('p')
			tag('list').may_only_be_parent_of('*')
			tag('list').may_not_contain_text
		end
	end
end