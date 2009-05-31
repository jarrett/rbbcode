require 'rubygems'
require 'test/unit'
require 'spec'

def puts(foo)
	raise 'puts called'
end

require File.expand_path(File.dirname(__FILE__) + '/../lib/rbbcode')