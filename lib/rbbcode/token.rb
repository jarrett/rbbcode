module RbbCode
	class Token
		# :possible_tag is a temporary type--it will only be the value until we decide if it's an opening tag, a closing tag, or just text
		TYPES = [:unknown, :text, :possible_tag, :opening_tag, :closing_tag]
		
		attr_reader :type
		attr_accessor :text # if the token is a tag, this will contain something like [b]
		attr_accessor :mate # a reference to the matching closing or opening tag.
		
		def has_value?
			raise(TokenTypeError, "Cannot call value on #{@type} tags") unless @type == :opening_tag
			@text.include?('=')
		end
		
		def initialize(_type)
			@type = _type
			@text = ''
			@mate = nil
		end
		
		def tag_name
			raise(TokenTypeError, "Cannot call tag_name on #{@type} tags") unless @type == :opening_tag or @type == :closing_tag
			# If text is like "[i]" or "[/i]", return "i"
			if @type == :opening_tag
				# Test if the token has a value. This is slightly more efficient than calling has_value? first, because we need the index anyway.
				if equal_index = @text.index('=')
					@text[1..(equal_index - 1)]
				else
					@text[1..-2]
				end
			else
				@text[2..-2]
			end
		end
		
		def tag_name=(name)
			case type
			when :opening_tag
				if v = self.value
					@text = "[#{name}=#{v}]"
				else
					@text = "[#{name}]"
				end
			when :closing_tag
				@text = "[/#{name}]"
			else
				raise "Can\'t set tag name for tags of type #{type}"
			end
		end
		
		def type=(t)
			raise(TokenTypeError, "Invalid token type: #{t}") unless TYPES.include?(t)
			@type = t
		end
		
		def value
			raise(TokenTypeError, "Cannot call value on #{@type} tags") unless @type == :opening_tag
			if equal_index = @text.index('=')
				@text[(equal_index + 1)..-2]
			else
				nil
			end
		end
	end
	
	class TokenTypeError < StandardError
	end
end