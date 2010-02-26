begin
	require 'jeweler'
	Jeweler::Tasks.new do |gemspec|
		gemspec.name = 'rbbcode'
		gemspec.summary = 'Ruby BB Code parser'
		gemspec.email = "jarrett@jarrettcolby.com"
		gemspec.homepage = "http://github.com/jarrett/rbbcode"
		gemspec.description = 'RbbCode is a customizable Ruby library for parsing BB Code. RbbCode validates and cleans input. It supports customizable schemas so you can set rules about what tags are allowed where. The default rules are designed to ensure valid HTML output.'
		gemspec.authors = ['Jarrett Colby']
		gemspec.files = Dir['lib/**/*.rb']
		gemspec.test_files = Dir['spec/**/*.rb']
		gemspec.add_development_dependency 'rspec', '>= 1.3.0'
		gemspec.add_dependency 'sanitize-url', '>= 0.1.3'
	end
	Jeweler::GemcutterTasks.new
rescue LoadError
	puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end