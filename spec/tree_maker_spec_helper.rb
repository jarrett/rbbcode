require 'pp'

module RbbCode
	class RootNode
		def == (other_node)
			self.children == other_node.children
		end
	end
	
	class TagNode
		def == (other_node)
			self.tag_name == other_node.tag_name and self.children == other_node.children
		end
	end
	
	class TextNode
		def == (other_node)
			self.text == other_node.text
		end
	end
end

class ExpectedTreeMaker
	include RbbCode
	
	def self.make(&block)
		maker = ExpectedTreeMaker.new
		maker.instance_eval(&block)
		maker.root
	end
	
	attr_reader :root
	
	protected
	
	def << (node)
		@current_parent.children << node
	end
	
	def initialize
		@root = RootNode.new
		@current_parent = @root
	end
	
	def text(contents, &block)
		self << TextNode.new(@current_parent, contents)
	end
	
	def tag(tag_name, value = nil, &block)
		tag_node = TagNode.new(@current_parent, tag_name, value)
		self << tag_node
		original_parent = @current_parent
		@current_parent = tag_node
		instance_eval(&block)
		@current_parent = original_parent
	end
end

module TreeMakerMatchers
	class MatchTree
		def initialize(expected_tree)
			@expected_tree = expected_tree
		end
		
		def matches?(target)
			@target = target
			@target == @expected_tree
		end
		
		def failure_message
			"Expected:\n\n#{pp_to_s(@expected_tree)}\n\nbut got:\n\n#{pp_to_s(@target)}"
		end
		
		def negative_failure_message
			"Expected anything other than:\n\n#{pp_to_s(@expected_tree)}"
		end
		
		protected
		
		def pp_to_s(obj)
			io = StringIO.new
			PP.pp(obj, io)
			io.rewind
			io.read
		end
	end
	
	def match_tree(expected_tree)
		MatchTree.new(expected_tree)
	end
end