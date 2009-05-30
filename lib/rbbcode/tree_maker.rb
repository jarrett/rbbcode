require 'pp'

module RbbCode
	module CharCodes
		CR_CODE = 13
		LF_CODE = 10
		
		L_BRACK_CODE = 91
		R_BRACK_CODE = 93
		SLASH_CODE = 47
		
		LOWER_A_CODE = 97
		LOWER_Z_CODE = 122
		
		UPPER_A_CODE = 65
		UPPER_Z_CODE = 90
	end
	
	class Node
		def << (child)
			@children << child
		end
		
		attr_accessor :children
		
		def initialize(parent)
			@parent = parent
			@children = []
		end
		
		attr_accessor :parent
	end
	
	class RootNode < Node
		def initialize
			@children = []
		end
	end
	
	class TextNode
		def initialize(parent, text)
			@parent = parent
			@text = text
		end
		
		attr_accessor :text
	end
	
	class TagNode < Node
		def self.from_opening_bb_code(parent, bb_code)
			if equal_index = bb_code.index('=')
				tag_name = bb_code[1, equal_index - 1]
				value = bb_code[(equal_index + 1)..-2]
			else
				tag_name = bb_code[1..-2]
				value = nil
			end
			new(parent, tag_name, value)
		end
		
		def initialize(parent, tag_name, value = nil)
			super(parent)
			@tag_name = tag_name
			@value = value
		end
		
		attr_reader :tag_name
		
		attr_reader :value
	end
	
	class TreeMaker
		include CharCodes
		
		def initialize(schema)
			@schema = schema
		end
		
		def make_tree(str)
			tree = RootNode.new
			# Initially, we open a paragraph tag. If it turns out that the first thing we encounter
			# is a block-level element, no problem: we'll be calling promote_block_level_elements
			# later anyway.
			current_parent = TagNode.new(tree, @schema.paragraph_tag_name)
			tree << current_parent
			current_token = ''
			current_token_type = :unknown
			str.each_byte do |char_code|
				char = char_code.chr
				case current_token_type
				when :unknown
					case char
					when '['
						current_token_type = :possible_tag
						current_token << char
					when "\r", "\n"
						current_token_type = :break
						current_token << char
					else
						current_token_type = :text
						current_token << char
					end
				when :text
					case char
					when "["
						current_parent << TextNode.new(current_parent, current_token)
						current_token = '['
						current_token_type = :possible_tag
					when "\r", "\n"
						current_parent << TextNode.new(current_parent, current_token)
						current_token = char
						current_token_type = :break
					else
						current_token << char
					end
				when :break
					if char == CR_CODE or char_code == LF_CODE
						current_token << char
					else
						if break_type(current_token) == :paragraph		
							puts "Paragraph break found. Current tree:"
							pp tree
							unless @schema.block_level?(current_parent.tag_name)
								# If the current parent isn't a paragraph or a block-level element,
								# we have a problem:
								# we're inside some other tag, and it hasn't been properly closed.
								# So, we need to take care of that.
								while current_parent.tag_name != @schema.paragraph_tag_name
									current_parent = current_parent.parent
								end
								current_parent = current_parent.parent
							end
						else # :line_break
							current_parent << TagNode.new(current_parent, @schema.line_break_tag_name)
						end
						if char == '['
							current_token = '['
							current_token_type = :possible_tag
						else
							current_token = char
							current_token_type = :text
						end
					end
				when :possible_tag
					case char
					when '['
						current_parent << TextNode.new(current_parent, '[')
						# No need to reset current_token or current_token_type
					when '/'
						current_token_type = :closing_tag
						current_token << '/'
					else
						if alphabetic_char?(char_code)
							current_token_type = :opening_tag
							current_token << char
						else
							current_token_type = :text
							current_token << char
						end
					end
				when :opening_tag
					if alphabetic_char?(char_code) or char == '='
						current_token << char
					elsif char == ']'
						current_token << ']'
						tag_node = TagNode.from_opening_bb_code(current_parent, current_token)
						if @schema.tag(tag_node.tag_name).valid_in_context?(*ancestor_list(current_parent))
							current_parent << tag_node
							current_parent = tag_node
							# else, don't do anything--the tag will be ignored
						end
						current_token_type = :unknown
						current_token = ''
					elsif char == "\r" or char == "\n"
						current_parent << TextNode.new(current_parent, current_token)
						current_token = char
						current_token_type = :break
					else
						current_token_type = :text
						current_token << char
					end
				when :closing_tag
					if alphabetic_char?(char_code)
						current_token << char
					elsif char == ']'
						original_parent = current_parent
						while current_parent.is_a?(TagNode) and current_parent.tag_name != current_token[2..-1]
							current_parent = current_parent.parent
						end
						if current_parent.is_a?(TagNode)
							current_parent = current_parent.parent
						else # current_parent is a RootNode
							# we made it to the top of the tree, and never found the tag to close
							# so we'll just ignore the closing tag altogether
							current_parent = original_parent
						end
						current_token_type = :unknown
						current_token = ''
					elsif char == "\r" or char == "\n"
						current_parent << TextNode.new(current_parent, current_token)
						current_token = char
						current_token_type = :break
					else
						current_token_type = :text
						current_token << char
					end
				end
			end
			# Handle whatever's left in the current token
			if current_token_type != :break
				current_parent << TextNode.new(current_parent, current_token)
			end
			tree
		end
		
		protected
		
		def alphabetic_char?(char_code)
			(char_code >= LOWER_A_CODE and char_code <= LOWER_Z_CODE) or (char_code >= UPPER_A_CODE and char_code <= UPPER_Z_CODE)
		end
		
		def ancestor_list(parent)
			ancestors = []
			while parent.is_a?(TagNode)
				ancestors << parent.tag_name
				parent = parent.parent
			end
			ancestors
		end
		
		def break_type(break_str)
			if break_str.length > 2
				:paragraph
			elsif break_str.length == 1
				:line_break
			elsif break_str == "\r\n"
				:line_break
			else
				:paragraph
			end
		end
	end
end