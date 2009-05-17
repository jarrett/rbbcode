module RbbCode
	class Cleaner
		def clean
			@tokens.select { |t| t.type == :opening_tag }.each do |opening_tag|
				
			end
			@tokens.select { |t| t.type == :closing_tag }.each do |closing_tag|
			end
		end
		
		def initialize(tokens)
			@tokens = tokens
		end
	end
end