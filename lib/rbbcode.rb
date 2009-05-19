$: << File.expand_path(File.dirname(__FILE__))

require 'rbbcode/parser'
require 'rbbcode/token'
require 'rbbcode/tokenizer'
require 'rbbcode/cleaner'
require 'rbbcode/html_maker'

module RbbCode
	# Don't change this -- override Parse#tag_allowed? in a subclass instead
	DEFAULT_ALLOWED_TAGS = [
		'b',
		'i',
		'u',
		'url',
		'img',
		'code',
		'quote'
	]
	
	# Don't change this -- override Parse#tag_to_html in a subclass instead
	DEFAULT_TAG_MAPPINGS = {
		'b' => 'strong',
		'i' => 'em',
		'u' => 'u',
		'code' => 'code',
		'quote' => 'blockquote'
	}
end