module RbbCode
	DEFAULT_ALLOWED_TAGS = [
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
		
	class SchemaTag
		def initialize(schema, name)
			@schema = schema
			@name = name
		end
		
		def may_be_nested
			@schema.allow_descent(@name, @name)
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
		
		def may_not_descend_from(tag_name)
			@schema.forbid_descent(tag_name, @name)
			self
		end
		
		def must_be_child_of(*tag_names)
			@schema.require_parents(tag_names, @name)
			self
		end
		
		def need_not_be_child_of(tag_name)
			@schema.unrequire_parent(tag_name, @name)
			self
		end
		
		# Returns true if tag_name is valid in the context defined by its list of ancestors.
		# ancestors should be ordered from most recent ancestor to most distant.
		def valid_in_context?(*ancestors)
			if ancestors.length == 1 and ancestors[0].is_a?(Array)
				ancestors = ancestors[0]
			end
			@schema.valid_in_context?(@name, ancestors)
		end
	end
	
	class Schema
		def allow_descent(ancestor, descendant) #:nodoc:
			if @forbidden_nestings.has_key?(descendant.to_s) and @forbidden_nestings[descendant.to_s].include?(ancestor.to_s)
				@forbidden_nestings[descendant.to_s].delete(ancestor.to_s)
			end
		end
		
		def allow_tag(name)
			unless @allowed_tags.include?(name.to_s)
				@allowed_tags << name.to_s
			end
		end
		
		def forbid_descent(ancestor, descendant) #:nodoc:
			@forbidden_nestings[descendant.to_s] ||= []
			unless @forbidden_nestings[descendant.to_s].include?(ancestor.to_s)
				@forbidden_nestings[descendant.to_s] << ancestor.to_s
			end
		end
		
		def forbid_tag(name)
			@allowed_tags.delete(name.to_s)
		end
		
		def initialize
			@allowed_tags = DEFAULT_ALLOWED_TAGS.dup
			@forbidden_nestings = {}
			@required_parents = {}
		end
		
		def require_parents(parents, child) #:nodoc:
			@required_parents[child.to_s] = parents.collect { |p| p.to_s }
			parents.each do |parent|
				if @forbidden_nestings.has_key?(child.to_s)
					@forbidden_nestings[child.to_s].delete(parent)
				end
			end
		end
		
		def tag(name)
			SchemaTag.new(self, name)
		end
		
		def unrequire_parent(parent, child)
			@required_parents.delete(child.to_s)
		end
		
		def valid_in_context?(tag_name, ancestors)
			return false unless @allowed_tags.include?(tag_name.to_s)
			if @required_parents.has_key?(tag_name.to_s) and !@required_parents[tag_name.to_s].include?(ancestors[0])
				return false
			end
			if @forbidden_nestings.has_key?(tag_name.to_s)
				@forbidden_nestings[tag_name.to_s].each do |forbidden_ancestor|
					return false if ancestors.include?(forbidden_ancestor)
				end
			end
			return true
		end
	end
end