# TODO: Lists must be surrounded by </p> and <p>

module RbbCode
	DEFAULT_TAG_MAPPINGS = {
		'p' => 'p',
		'br' => 'br',
		'b' => 'strong',
		'i' => 'em',
		'u' => 'u',
		'code' => 'code',
		'quote' => 'blockquote',
		'list' => 'ul',
		'*' => 'li'
	}
	
	class HtmlMaker
		def make_html(node)
			output = ''
			case node.class.to_s
			when 'RbbCode::RootNode'
				node.children.each do |child|
					output << make_html(child)
				end
			when 'RbbCode::TagNode'
				custom_tag_method = "html_from_#{node.tag_name}_tag"
				if respond_to?(custom_tag_method)
					output << send(custom_tag_method, node)
				else
					inner_html = ''
					node.children.each do |child|
						inner_html << make_html(child)
					end
					output << content_tag(map_tag_name(node.tag_name), inner_html)
				end
			when 'RbbCode::TextNode'
				output << node.text
			else
				raise "Don't know how to make HTML from #{node.class}"
			end
			output
		end
		
		protected
		
		def content_tag(tag_name, contents, attributes = {})
			output = "<#{tag_name}"
			attributes.each do |attr, value|
				output << " #{attr}=\"#{value}\""
			end
			if contents.nil? or contents.empty?
				output << '/>'
			else
				output << ">#{contents}</#{tag_name}>"
			end
		end
		
		def html_from_img_tag(node)
			"<img src=\"\" alt=\"\"/>"
			raise 'not implemented'
		end

		def html_from_url_tag(node)
			raise 'not implemented'
		end
		
		def map_tag_name(tag_name)
			unless DEFAULT_TAG_MAPPINGS.has_key?(tag_name)
				raise "No tag mapping for '#{tag_name}'"
			end
			DEFAULT_TAG_MAPPINGS[tag_name]
		end
	end
end