module RbbCode
	class RootNode
		def == (other_node)
			self.class == other_node.class and self.children == other_node.children
		end
		
		def print_tree(indent = 0)
			output = ''
			indent.times { output << "  " }
			output << 'ROOT'
			children.each do |child|
				output << "\n" << child.print_tree(indent + 1)
			end
			output << "\n/ROOT"
			output
		end
	end
	
	class TagNode
		def == (other_node)
			self.class == other_node.class and self.tag_name == other_node.tag_name and self.value == other_node.value and self.children == other_node.children
		end
		
		def print_tree(indent = 0)
			output = ''
			indent.times { output << "  " }
			if value.nil?
				output << "[#{tag_name}]"
			else
				output << "[#{tag_name}=#{value}]"
			end
			children.each do |child|
				output << "\n" << child.print_tree(indent + 1)
			end
			output << "\n"
			indent.times { output << "  " }
			output << "[/#{tag_name}]"
			output
		end
	end
	
	class TextNode
		def == (other_node)
			self.class == other_node.class and self.text == other_node.text
		end
		
		def print_tree(indent = 0)
			output = ''
			indent.times { output << "  " }
			output << '"' << text << '"'
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
			"Expected:\n\n#{@expected_tree.print_tree}\n\nbut got:\n\n#{@target.print_tree}"
		end
		
		def negative_failure_message
			"Expected anything other than:\n\n#{@expected_tree.print_tree}"
		end
	end
	
	def match_tree(expected_tree)
		MatchTree.new(expected_tree)
	end
end