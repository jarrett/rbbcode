module RbbCode
	class Tokenizer
		UPPERCASE_A_CODE = 65
		UPPERCASE_Z_CODE = 90
		LOWERCASE_A_CODE = 97
		LOWERCASE_Z_CODE = 122
		
		ALLOWED_VALUE_CHARS = [':', '/', '.', '?', '&', '=']
		
		def tokenize(str)
			@tokens = []
			@current_token = Token.new(:unknown)
			str.each_byte do |char_code|
				char = char_code.chr
				case @current_token.type
				when :unknown
					# Since the type is still unknown, we're at the start of a new token
					if char == '['
						# It might be a tag if it starts with [
						@current_token.type = :possible_tag
					else
						# It's not a tag
						@current_token.type = :text
					end
					@current_token.text << char
				when :possible_tag
					# The last character was [, so we might be in a tag
					if alphabetic_char?(char_code)
						# The first character after [ is alphabetic, so we'll tentatively declare this an opening tag
						@current_token.type = :opening_tag
						@current_token.text << char
					elsif char == '/'
						# The first character after [ is /, so we'll tentatively declare this a closing tag
						@current_token.type = :closing_tag
						@current_token.text << char
					else
						# The last token turned out not to be a tag
						invalidate_tag_token(char)
					end
				when :text
					# Unless we're about to enter a tag, we just keep adding to the text token
					if char == '['
						# Create a new token, because a tag might be coming
						@tokens << @current_token
						@current_token = Token.new(:possible_tag)
					end
					@current_token.text << char
				when :opening_tag, :closing_tag
					if alphabetic_char?(char_code) or (@current_token.type == :opening_tag and char == '=')
						# In the tag name
						@current_token.text << char
					elsif char == ']'
						@current_token.text << ']'
						@tokens << @current_token
						@current_token = Token.new(:unknown)
					elsif @current_token.type == :opening_tag and @current_token.has_value? and ALLOWED_VALUE_CHARS.include?(char)
						@current_token.text << char
					else
						# The last token turned out not to be a tag
						invalidate_tag_token(char)
					end
				end
			end
			# Push the last token onto the array if it's not empty
			unless @current_token.text.empty?
				@current_token.type = :text # If we thought it was a tag, we were wrong
				@tokens << @current_token
			end
			@tokens
		end
		
		protected
		
		def alphabetic_char?(char_code)
			(char_code >= UPPERCASE_A_CODE and char_code <= UPPERCASE_Z_CODE) or (char_code >= LOWERCASE_A_CODE and char_code <= LOWERCASE_Z_CODE)
		end
		
		def invalidate_tag_token(char)
			@current_token.type = :text
			if @tokens.last.type == :text
				@tokens.last.text << @current_token.text
			else
				@tokens << @current_token
			end
			if char == '['
				# Even though the last one wasn't a tag, this one might be
				@current_token = Token.new(:possible_tag)
			elsif @tokens.last.type == :text
				@current_token = @tokens.pop
			else
				@current_token = Token.new(:text)
			end
			@current_token.text << char
		end
	end
end