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
    if !instance_variable_defined?(:@grammar_loaded) or !@grammar_loaded
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
      :output_format => :html,
      :sanitize => true,
      :sanitize_config => RbbCode::DEFAULT_SANITIZE_CONFIG
    }.merge(options)
  end
  
  def convert(bb_code)
    # Collapse CRLFs to LFs. Then replace any solitary CRs with LFs.
    bb_code = bb_code.gsub("\r\n", "\n").gsub("\r", "\n")
    output = self.class.parser_class.new.parse("\n\n" + bb_code + "\n\n").send("to_#{@options[:output_format]}")
    if @options[:emoticons]
      output = convert_emoticons(output)
    end
    # Sanitization works for HTML only.
    if @options[:output_format] == :html and @options[:sanitize]
      Sanitize.clean(output, @options[:sanitize_config])
    else
      output
    end
  end

  def convert_emoticons(output)
    @options[:emoticons].each do |emoticon, url|
      output.gsub!(emoticon, '<img src="' + url + '" alt="Emoticon"/>')
    end
    output
  end

  def output_format
    @options[:output_format]
  end
end