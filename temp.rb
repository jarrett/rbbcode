str1 = 'javascript'
str2 = 'javascript:'
str3 = 'JavaScript'
str4 = 'JavaScript:'

[str1, str2, str3, str4].each do |str|
	puts str
	str = str.gsub(/j\s*\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:?/i) do |match_str|
		('%' + match_str.unpack('H2' * match_str.length).join('%')).upcase
	end
	puts str
end