module RbbCode
	class Parser
		def initialize(config = {})
			config.each_key do |key|
				raise(ArgumentError, "Unknown option #{key}") unless known_options.include?(key)
			end
			@config = config
		end
		
		def parse(str)
			str = escape_html_tags(str)
			
			schema = @config[:schema] || RbbCode::Schema.new
			
			tree_maker = @config[:tree_maker] || RbbCode::TreeMaker.new(schema)
			tree = tree_maker.make_tree(str)
			
			html_maker = @config[:html_maker] || RbbCode::HtmlMaker.new
			html_maker.make_html(tree)
		end
		
		protected
		
		def escape_html_tags(str)
			str.gsub('<', '&lt;').gsub('>', '&gt;')
		end
		
		def known_options
			[:schema, :tree_maker, :html_maker]
		end
	end
end
