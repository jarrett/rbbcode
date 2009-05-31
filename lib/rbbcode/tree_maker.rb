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
	
	class TextNode < Node
		
		undef_method '<<'.to_sym
		undef_method :children
		
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
			delete_empty_paragraphs(parse_str(str))
		end
		
		protected
		
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
		
		def delete_empty_paragraphs(node)
			node.children.reject! do |child|
				if child.is_a?(TagNode)
					if !child.children.empty?
						delete_empty_paragraphs(child)
						false
					elsif child.tag_name == @schema.paragraph_tag_name
						# It's an empty paragraph tag, so the reject! block should return true
						true
					else
						false
					end
				else
					false
				end
			end
			node
		end
		
		def parse_str(str)
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
						if current_parent.is_a?(RootNode)
							new_paragraph_tag = TagNode.new(current_parent, @schema.paragraph_tag_name)
							current_parent << new_paragraph_tag
							current_parent = new_paragraph_tag
						end
						current_token_type = :text
						current_token << char
					end
				when :text
					case char
					when "["
						if @schema.text_valid_in_context?(*ancestor_list(current_parent))
							current_parent << TextNode.new(current_parent, current_token)
						end
						current_token = '['
						current_token_type = :possible_tag
					when "\r", "\n"
						if @schema.text_valid_in_context?(*ancestor_list(current_parent))
							current_parent << TextNode.new(current_parent, current_token)
						end
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
							while current_parent.is_a?(TagNode) and !@schema.block_level?(current_parent.tag_name) and current_parent.tag_name != @schema.paragraph_tag_name
								current_parent = current_parent.parent
							end
							# The current parent might be a paragraph tag, in which case we should move up one more level.
							# Otherwise, it might be a block-level element or a root node, in which case we should not move up.
							if current_parent.is_a?(TagNode) and current_parent.tag_name == @schema.paragraph_tag_name
								current_parent = current_parent.parent
							end
							# Regardless of whether the current parent is a block-level element, we need to open a new paragraph.
							new_paragraph_node = TagNode.new(current_parent, @schema.paragraph_tag_name)
							current_parent << new_paragraph_node
							current_parent = new_paragraph_node
						else # line break
							prev_sibling = current_parent.children.last
							if prev_sibling.is_a?(TagNode) and @schema.block_level?(prev_sibling.tag_name)
								# Although the input only contains a single newline, we should
								# interpret is as the start of a new paragraph, because the last
								# thing we encountered was a block-level element.
								new_paragraph_node = TagNode.new(current_parent, @schema.paragraph_tag_name)
								current_parent << new_paragraph_node
								current_parent = new_paragraph_node
							elsif @schema.tag(@schema.line_break_tag_name).valid_in_context?(*ancestor_list(current_parent))
								current_parent << TagNode.new(current_parent, @schema.line_break_tag_name)
							end
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
						if tag_name_char?(char_code)
							current_token_type = :opening_tag
							current_token << char
						elsif tag_name
							current_token_type = :text
							current_token << char
						end
					end
				when :opening_tag
					if tag_name_char?(char_code) or char == '='
						current_token << char
					elsif char == ']'
						current_token << ']'
						tag_node = TagNode.from_opening_bb_code(current_parent, current_token)
						if @schema.block_level?(tag_node.tag_name) and current_parent.tag_name == @schema.paragraph_tag_name
							# If there is a line break before this, it's superfluous and should be deleted
							prev_sibling = current_parent.children.last
							if prev_sibling.is_a?(TagNode) and prev_sibling.tag_name == @schema.line_break_tag_name
								current_parent.children.pop
							end
							# Promote a block-level element
							current_parent = current_parent.parent
							tag_node.parent = current_parent
							current_parent << tag_node
							current_parent = tag_node
							# If all of this results in empty paragraph tags, no worries: they will be deleted later.
						elsif @schema.tag(tag_node.tag_name).valid_in_context?(*ancestor_list(current_parent))
							current_parent << tag_node
							current_parent = tag_node
						end # else, don't do anything--the tag is invalid and will be ignored
						current_token_type = :unknown
						current_token = ''
					elsif char == "\r" or char == "\n"
						current_parent << TextNode.new(current_parent, current_token)
						current_token = char
						current_token_type = :break
					elsif current_token.include?('=')
						current_token << char
					else
						current_token_type = :text
						current_token << char
					end
				when :closing_tag
					if tag_name_char?(char_code)
						current_token << char
					elsif char == ']'
						original_parent = current_parent
						puts current_token[2..-1]
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
			if current_token_type != :break and !current_token.empty?
				current_parent << TextNode.new(current_parent, current_token)
			end
			tree
		end
		
		def tag_name_char?(char_code)
			(char_code >= LOWER_A_CODE and char_code <= LOWER_Z_CODE) or (char_code >= UPPER_A_CODE and char_code <= UPPER_Z_CODE) or char_code.chr == '*'
		end
	end	
end