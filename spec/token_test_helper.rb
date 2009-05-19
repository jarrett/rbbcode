module TokenTestHelper
	def make_tokens(tuples)
		tuples.collect do |tuple|
			token = RbbCode::Token.new(tuple[0])
			token.text = tuple[1]
			token
		end
	end
end