module RbbCode
	class Cleaner
		DEFAULT_ALLOWED_TAGS = [
			'b',
			'i',
			'u',
			'url',
			'img',
			'code',
			'quote',
			'list',
			'*'
		]
		
		def clean
			mate_tags
			apply_schema
			@tokens
		end
		
		def errors?
			@errors
		end
		
		def initialize(tokens, schema)
			@tokens = tokens
			@errors = false
			@schema = schema
		end
		
		protected
		
		def apply_schema
			open_tags = []
			@tokens.each_with_index do |token, i|
				if token.type == :opening_tag
					if @schema.tag(token.tag_name).valid_in_context?(open_tags)
						open_tags << token.tag_name
					else
						@tokens.delete(token)
						@tokens.delete(token.mate)
					end
				elsif token.type == :closing_tag
					# By now, the tags should be properly mated and nested, so we can
					# just blindly pop the last tag off the stack
					open_tags.pop
				end
			end
		end
		
		def mate_tags
			open_tags = []
			resulting_tokens = []
			@tokens.each do |token|
				case token.type
				when :opening_tag
					open_tags << token
					resulting_tokens << token
				when :text
					resulting_tokens << token
				when :closing_tag
					tag_name = token.tag_name
					unless open_tags.empty?
						if tag_name == open_tags.last.tag_name
							open_tags.last.mate = token
							token.mate = open_tags.last
							open_tags.pop
							resulting_tokens << token
						else
							# An out-of-place closing tag. Try to find a mate further down the stack.
							# If a mate is found, force all subsequent tags to close.
							(open_tags.length - 1).downto(0) do |i|
								if open_tags[i].tag_name == tag_name
									open_tags[i].mate = token
									token.mate = open_tags[i]
									(open_tags.length - 1).downto(i + 1) do |j|
										closing_tag = Token.new(:closing_tag)
										closing_tag.tag_name = open_tags[j].tag_name
										closing_tag.mate = open_tags[j]
										open_tags[j].mate = closing_tag
										resulting_tokens << closing_tag
										open_tags.pop
									end
									open_tags.pop
									resulting_tokens << token
									break;
								end
							end
							# If we get to the bottom of the stack and haven't mated the tag,
							# we'll leave it out of the results
							@errors = true
						end
					else
						@errors = true
					end
				else
					raise "Unrecognized token type: #{token.type}"
				end
				
			end
			unless open_tags.empty?
				open_tags.each do |opening_tag|
					closing_tag = Token.new(:closing_tag)
					closing_tag.tag_name = opening_tag.tag_name
					resulting_tokens << closing_tag
				end
				@errors = true
			end
			@tokens = resulting_tokens
		end
	end
end