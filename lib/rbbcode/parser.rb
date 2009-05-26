module RbbCode
	class Parser
		def initialize(config = {})
			@config = config
		end
		
		def parse(str)
			str = escape_html_tags(str)
			
			tokenizer = @config[:tokenizer] || RbbCode::Tokenizer.new
			tokens = tokenizer.tokenize(str)
			
			if @config.has_key?(:schema)
				schema = @config[:schema]
			else
				schema = RbbCode::Schema.new
				schema.use_defaults
			end
			
			line_breaker = @config[:line_breaker] || RbbCode::LineBreaker.new
			
			cleaner = @config[:cleaner] || RbbCode::Cleaner.new(schema, line_breaker)
			tokens = cleaner.clean(tokens)
			
			html_maker = @config[:html_maker] || RbbCode::HtmlMaker.new
			html_maker.make_html(tokens)
		end
		
		protected
		
		def escape_html_tags(str)
			str.gsub('<', '&lt;').gsub('>', '&gt;')
		end
	end
end