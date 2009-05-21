

module RbbCode
	class Tree
		attr_accessor :children
		
		def initialize
			@children = []
		end
	end
	
	class Branch < Tree
		attr_accessor :opening_tag, :parent
		
		def initialize(opening_tag, parent)
			@opening_tag = opening_tag
			@parent = parent
			super()
		end
	end
	
	class HtmlMaker
		DEFAULT_TAG_MAPPINGS = {
			'b' => 'strong',
			'i' => 'em',
			'u' => 'u',
			'code' => 'code',
			'quote' => 'blockquote',
			'list' => 'ul',
			'*' => 'li'
		}
		
		def initialize(tokens)
			@tokens = tokens
		end
		
		# IDEA: before converting to HTML tags, loop over @tokens and create a tree of tags. Then generate HTML recursively for each branch.
		
		def make_html
			tree = Tree.new
			current_branch = tree
			@tokens.each do |token|
				case token.type
				when :text
					current_branch.children << token.text
				when :opening_tag
					new_branch = Branch.new(token, current_branch)
					current_branch.children << new_branch
					current_branch = new_branch
				when :closing_tag
					current_branch = current_branch.parent
				end
			end
			debug_tree(tree)
		end
		
		attr_accessor :schema
		
		protected
		
		def debug_tree(tree, indent_level = 0)
			tree.children.each do |child|
				if child.is_a?(String)
					debug_tree_puts('"' + child + '"', indent_level)
				else
					debug_tree_puts(child.opening_tag.tag_name, indent_level)
					debug_tree(child, indent_level + 1)
				end
			end
		end
		
		def debug_tree_puts(str, indent_level)
			output = ''
			indent_level.times do
				output << '  '
			end
			puts(output + str)
		end
				
		def make_tag(tag_name, opening_closing_or_self_closing, attributes = {})
			output = '<'
			if opening_closing_or_self_closing == :closing
				output << '/'
			end
			output << tag_name
			attributes.each do |attr, value|
				output << " #{attr}=\"#{value}\""
			end
			if opening_closing_or_self_closing == :self_closing
				output << '/'
			end
			output << '>'
		end
	end
end