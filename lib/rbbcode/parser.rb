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
			
			cleaner = @config[:cleaner_class].new(tokens, RbbCode::Schema.new)
			tokens = cleaner.clean
			
			tokens = remove_forbidden_tags(tokens)
			
			html_maker = @config[:html_maker_class].new(tokens)
			if @config.has_key?(:schema)
				html_maker.schema = @config[:schema]
			end
			html_maker.make_html
		end
		
		protected
		
		def escape_html_tags(str)
			str.gsub('<', '&lt;').gsub('>', '&gt;')
		end
	end
end