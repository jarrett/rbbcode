Gem::Specification.new do |s|
	s.name = 'rbbcode'
	s.version = "0.1.0"
	s.date = File.mtime('rbbcode.gemspec')
	s.authors = ['Jarrett Colby']
	s.email = 'jarrett@uchicago.edu'
	s.summary = 'Ruby BB Code parser'
	File.open('README') { |f| s.description = f.read }
	s.files = ['README', 'MIT-LICENSE', 'lib/rbbcode.rb'] + Dir.glob('lib/rbbcode/*.rb')
end