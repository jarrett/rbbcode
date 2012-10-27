require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
end

task :build do
  `rm *.gem`
  `gem build rbbcode.gemspec`
end

task :install do
  `gem install rbbcode.gem`
end

task :release do
  `gem push #{Dir.glob('rbbcode-*.*.*.gem').first}`
end