module RbbCode
	class LineBreaker
		LF_CODE = 10
		CR_CODE = 13
		
		def break_lines(str)
			@output = '[p]'
			state = :no_break
			str.each_byte do |char_code|
				case state
				when :no_break
					case char_code
					when CR_CODE
						state = :cr
					when LF_CODE
						state = :lf
					else
						@output << char_code.chr
					end
				when :cr
					case char_code
					when CR_CODE
						append_p_pair
						state = :no_break
					when LF_CODE
						state = :cr_lf
					else
						append_br_pair
						@output << char_code.chr
						state = :no_break
					end
				when :lf
					case char_code
					when CR_CODE
						append_br_pair
						state = :cr
					when LF_CODE
						append_p_pair
						state = :no_break
					else
						append_br_pair
						@output << char_code.chr
						state = :no_break
					end
				when :cr_lf
					case char_code
					when CR_CODE
						state = :cr_lf_cr
					when LF_CODE
						append_p_pair
						state = :no_break
					else
						append_br_pair
						@output << char_code.chr
						state = :no_break
					end
				when :cr_lf_cr
					case char_code
					when CR_CODE, LF_CODE
						append_p_pair
						state = :no_break
					else
						append_p_pair
						@output << char_code.chr
						state = :no_break
					end
				else
					raise "Unknown state: #{state}"
				end
				last_char_code = char_code
			end
			@output << '[/p]'
		end
		
		protected
		
		def append_br_pair
			@output << '[br][/br]'
		end
		
		def append_p_pair
			@output << '[/p][p]'
		end
	end
end