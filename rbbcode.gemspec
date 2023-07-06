Gem::Specification.new do |s|
  s.name         = 'rbbcode'
  s.version      = '1.1.0'
  s.date         = '2020-06-20'
  s.summary      = 'RbbCode'
  s.description  = 'Converts BBCode to HTML. Gracefully handles invalid input.'
  s.authors      = ['Jarrett Colby']
  s.email        = 'jarrett@madebyhq.com'
  s.files        = Dir.glob('lib/**/*')
  s.homepage     = 'https://github.com/jarrett/rbbcode'
  
  s.add_runtime_dependency     'treetop', '1.5.3'
  s.add_runtime_dependency     'sanitize', '>= 6.0.2' # See CVE-2023-36823
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'lorax', '>= 0.3.0.rc2'
  s.add_development_dependency 'rake'
  
  s.post_install_message = File.read(File.join(File.dirname(__FILE__), 'post_install_message.txt'))
end