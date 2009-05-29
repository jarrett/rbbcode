module RbbCode
	class Parser
		def initialize(config = {})
			@config = config
		end
		
		def parse(str)
			str = escape_html_tags(str)
			
			tree_maker = @config[:tree_maker] || RbbCode::TreeMaker.new
			
			html_maker.make_html(tree)
		end
		
		protected
		
		def escape_html_tags(str)
			str.gsub('<', '&lt;').gsub('>', '&gt;')
		end
	end
end