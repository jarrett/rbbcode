# Uncomment this when developing:
#$:.unshift './lib'

require 'erb'
require 'rubygems'
require 'treetop'
require 'sanitize'
require 'rbbcode/node_extensions'
require 'rbbcode/sanitize'

class RbbCode  
  def self.parser_class
    if !@grammar_loaded
      Treetop.load_from_string(
        ERB.new(
          File.read(
            File.join(
              File.dirname(__FILE__),
              'rbbcode/rbbcode_grammar.treetop'
            )
          )
        ).result
      )
      @grammar_loaded = true
    end
    RbbCodeGrammarParser
  end
  
  def initialize(options = {})
    @options = {
      :sanitize => true,
      :sanitize_config => RbbCode::DEFAULT_SANITIZE_CONFIG,
      :transformers => COLOR_PROCESSOR
    }.merge(options)
  end
  
  def convert(bb_code)
    html = self.class.parser_class.new.parse("\n\n" + bb_code + "\n\n").to_html
    if @options[:emoticons]
      @options[:emoticons].each do |emoticon, url|
        html.gsub!(emoticon, '<img src="' + url + '" alt="Emoticon"/>')
      end
    end
    html
    if @options[:sanitize]
      Sanitize.clean(html, @options[:sanitize_config])
    else
      html
    end
  end
end