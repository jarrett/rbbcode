module RbbCode
	class Parser
		def initialize(config = {})
			@config = config
		end
		
		def parse(str)
			str = escape_html_tags(str)
			tokens = Tokenizer.new(str).tokenize
			tokens = Cleaner.new(tokens).clean
			output = ''
			output
		end
		
		protected
		
		def tag_allowed?(tag)
			DEFAULT_ALLOWED_TAGS.include?(tag)
		end
		
		def escape_html_tags(str)
			str.gsub('<', '&lt;').gsub('>', '&gt;')
		end
		
		def tag_mappings
			DEFAULT_TAG_MAPPINGS
		end
		
		def tag_to_html(tag_name, contents)
			
		end
	end
end