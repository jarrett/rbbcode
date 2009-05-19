module RbbCode
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
		
		def make_html
			
		end
		
		attr_accessor :schema
	end
end