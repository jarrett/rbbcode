# TODO: Lists must be surrounded by </p> and <p>

module RbbCode
	DEFAULT_TAG_MAPPINGS = {
		'b' => 'strong',
		'i' => 'em',
		'u' => 'u',
		'code' => 'code',
		'quote' => 'blockquote',
		'list' => 'ul',
		'*' => 'li'
	}
	
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
		def make_html(tokens)
			tree = html_from_tree(make_tree(tokens))
		end
		
		protected
		
		def bb_code_tag_to_html_tag(tag_name)
			unless DEFAULT_TAG_MAPPINGS.has_key?(tag_name)
				raise "No tag mapping for '#{tag_name}'"
			end
			DEFAULT_TAG_MAPPINGS[tag_name]
		end
		
		def content_tag(tag_name, contents, attributes = {})
			output = "<#{tag_name}"
			attributes.each do |attr, value|
				output << " #{attr}=\"#{value}\""
			end
			output << ">#{contents}</#{tag_name}>"
		end
		
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
				output << "\t"
			end
			puts(output + str)
		end
		
		def html_from_img_tag(branch)
			"<img src=\"\" alt=\"\"/>"
			raise 'not implemented'
		end
		
		def html_from_tree(tree)
			output = ''
			tree.children.each do |child|
				if child.is_a?(String)
					output << child
				else
					if respond_to?("html_from_#{child.opening_tag.tag_name}_tag")
						output << send("html_from_#{child.opening_tag.tag_name}_tag", child)
					else
						tag_name = bb_code_tag_to_html_tag(child.opening_tag.tag_name)
						output << content_tag(tag_name, html_from_tree(child))
					end
				end
			end
			output
		end
		
		def html_from_url_tag(branch)
			raise 'not implemented'
		end
		
		def make_tree(tokens)
			tree = Tree.new
			current_branch = tree
			tokens.each do |token|
				case token.type
				when :text
					current_branch.children << token.text
				when :opening_tag
					new_branch = Branch.new(token, current_branch)
					current_branch.children << new_branch
					current_branch = new_branch
				when :closing_tag
					begin
						current_branch = current_branch.parent
					rescue
						raise tokens.inspect
					end
				end
			end
			#debug_tree(tree)
			tree
		end
	end
end