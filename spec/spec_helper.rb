require 'rubygems'
require 'test/unit'
require 'rspec'

#def puts(foo)
#	raise 'puts called'
#end

require File.expand_path(File.dirname(__FILE__) + '/../lib/rbbcode')

class CustomHtmlMaker < RbbCode::HtmlMaker
  
  def html_from_br_tag(node)
    '<br />'
  end
  
  def html_from_Qsmiley_tag(node)
    '<smiley />'
  end
  
end
