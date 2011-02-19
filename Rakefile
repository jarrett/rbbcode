require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'

Jeweler::Tasks.new do |gem|
	gem.name = 'rbbcode'
	gem.homepage = "http://github.com/jarrett/rbbcode"
	gem.license = "MIT"
	gem.summary = 'Ruby BB Code parser'
	gem.description = 'RbbCode is a customizable Ruby library for parsing BB Code. RbbCode validates and cleans input. It supports customizable schemas so you can set rules about what tags are allowed where. The default rules are designed to ensure valid HTML output.'
	gem.email = "jarrett@jarrettcolby.com, aq1018@gmail.com"
	gem.authors = ['Jarrett Colby', "aq1018@gmail.com"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
  spec.rspec_opts = "--color --format progress"
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new