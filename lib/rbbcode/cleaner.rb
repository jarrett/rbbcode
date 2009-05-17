module RbbCode
	class Cleaner
		def clean
			@tokens.each_with_index do |token, i|
				if token.type == :opening_tag
					tokens_after = @tokens[i..-1]
					if closing_tag = tokens_after.find { |t| t.type == :closing_tag and t.tag_name == token.tag_name and t.mate.nil? }
						token.mate = closing_tag
						closing_tag.mate = token
					else
						@tokens.delete_at(i)
						@errors = true
					end
				end
			end
			
			@tokens.each_with_index do |token, i|
				# We've already matched all opening tags, so any closing tag without a mate must be invalid
				if token.type == :closing_tag and token.mate.nil?
					@tokens.delete_at(i)
					@errors = true
				end
			end
			
			@tokens
		end
		
		def errors?
			@errors
		end
		
		def initialize(tokens)
			@tokens = tokens
			@errors = false
		end
	end
end