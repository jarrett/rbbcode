# TODO: Lists must be surrounded by </p> and <p>

require 'cgi'

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
			src = sanitize_url(node.inner_bb_code)
			content_tag('img', nil, {'src' => src, 'alt' => ''})
		end

		def html_from_url_tag(node)
			inner_bb_code = node.inner_bb_code
			if node.value.nil?
				url = inner_bb_code
			else
				url = node.value
			end
			url = sanitize_url(url)
			content_tag('a', inner_bb_code, {'href' => url})
		end
		
		def map_tag_name(tag_name)
			unless DEFAULT_TAG_MAPPINGS.has_key?(tag_name)
				raise "No tag mapping for '#{tag_name}'"
			end
			DEFAULT_TAG_MAPPINGS[tag_name]
		end
		
		def sanitize_url(url)
			# Prepend a protocol if there isn't one
			unless url.match(/^[a-zA-Z]+:\/\//)
				url = 'http://' + url
			end
			# Replace all functional permutations of "javascript:" with a hex-encoded version of the same
			url.gsub(/(\s*j\s*\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*):/i) do |match_str|
				CGI::escape($1) + '%3A'
			end
		end
	end
end