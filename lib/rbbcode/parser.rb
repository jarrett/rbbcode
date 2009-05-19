module RbbCode
	class Parser
		def initialize(config = {})
			@config = {
				:tokenizer_class => RbbCode::Tokenizer,
				:cleaner_class => RbbCode::Cleaner,
				:html_maker_class => RbbCode::HtmlMaker
			}.merge(config)
		end
		
		def parse(str)
			str = escape_html_tags(str)
			
			tokenizer = @config[:tokenizer_class].new(str)
			tokens = tokenizer.tokenize
			
			cleaner = @config[:cleaner_class].new(tokens)
			tokens = cleaner.clean
			
			tokens = remove_forbidden_tags(tokens)
			
			html_maker = @config[:html_maker_class].new(tokens)
			html_maker.make_html
		end
		
		protected
		
		def escape_html_tags(str)
			str.gsub('<', '&lt;').gsub('>', '&gt;')
		end
		
		def remove_forbidden_tags(tokens)
			tokens.reject do |token|
				(token.type == :opening_tag or token.type == :closing_tag) and !tag_allowed?(token.tag_name)
			end
		end
		
		def tag_allowed?(tag_name)
			DEFAULT_ALLOWED_TAGS.include?(tag_name)
		end
		
		def tag_mappings
			DEFAULT_TAG_MAPPINGS
		end
	end
end