require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
end

def built_gem_name
  Dir.glob('rbbcode-*.*.*.gem').first
end

task :build do
  `rm *.gem`
  puts `gem build rbbcode.gemspec`
end

task :install do
  puts `gem install #{built_gem_name}`
end

task :release do
  # Use exec to replace the current process in case
  # RubyGems prompts us for username etc.
  exec "gem push #{built_gem_name}"
end