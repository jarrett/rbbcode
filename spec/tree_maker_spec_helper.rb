require 'pp'

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
			equal_nodes?(@target, @expected_tree)
		end
		
		def failure_message
			"Expected:\n\n#{pp_to_s(@expected_tree)}\n\nbut got:\n\n#{pp_to_s(@target)}"
		end
		
		def negative_failure_message
			"Expected anything other than:\n\n#{pp_to_s(@expected_tree)}"
		end
		
		protected
		
		def equal_nodes?(node_1, node_2)
			return false unless node_1.class == node_2.class
			case node_1.class.to_s
			when 'RbbCode::TextNode'
				node_1.text == node_2.text
			when 'RbbCode::RootNode', 'RbbCode::TagNode'
				return false unless node_1.is_a?(RbbCode::RootNode) or node_1.tag_name == node_2.tag_name
				node_1.children.each_with_index do |node_1_child, i|
					unless equal_nodes?(node_1_child, node_2.children[i])
						#return false
					end
				end
				return true
			end
		end
		
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