module RbbCode
	class Token
		# :possible_tag is a temporary type--it will only be the value until we decide if it's an opening tag, a closing tag, or just text
		TYPES = [:unknown, :text, :possible_tag, :opening_tag, :closing_tag]
		
		attr_reader :type
		attr_accessor :text # if the token is a tag, this will contain something like [b]
		attr_accessor :mate # a reference to the matching closing or opening tag
		
		def initialize(_type)
			@type = _type
			@text = ''
			@mate = nil
		end
		
		def tag_name
			# If text is like "[i]" or "[/i]", return "i"
			if @type == :opening_tag
				@text[1..-2]
			else
				@text[2..-2]
			end
		end
		
		def type=(t)
			if TYPES.include?(t)
				@type = t
			else
				raise "Invalid token type: #{t}"
			end
		end
	end
end