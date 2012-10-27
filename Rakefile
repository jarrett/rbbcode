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
  puts `gem push #{built_gem_name}`
end