require 'pp'

class Foo
	attr_accessor :child
	
	def initialize(text)
		@text = text
	end
	
	def pretty_print(pp)
		pp.text @text
		pp.group(1, '{', '}') do
			pp.breakable
			pp @child
		end
	end
end

tree = Foo.new 'Level 1'
tree.child = Foo.new 'Level 2'
tree.child.child = Foo.new 'Level 3'

pp tree