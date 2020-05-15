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
      load_grammar
      @grammar_loaded = true
    end
    RbbCodeGrammarParser
  end

  def initialize(options = {})
    @options = {
      :to_markup => :html,
      :sanitize => true,
      :sanitize_config => RbbCode::DEFAULT_SANITIZE_CONFIG
    }.merge(options)

#    raise("#{options[:to_markup]} is not supported. Only :html and :markdown allowed")
#      unless options[:to_markup].in?(%i[markdown html])
  end

  def convert(bb_code)
    markup = convert_to_markup(bb_code)

    @options.fetch(:emoticons, []).each do |emoticon, url|
      if to_markup == :markdown
        markup.gsub!(emoticon, '![Emoticon](' + url + ')')
      else
        markup.gsub!(emoticon, '<img src="' + url + '" alt="Emoticon"/>')
      end
    end

    if sanitize?
      Sanitize.clean(markup, @options[:sanitize_config])
    else
      markup
    end
  end

  def to_markup
    @options[:to_markup].to_sym
  end

  def parser
    @parser ||= self.class.parser_class.new
  end

  def sanitize?
    to_markup == :html && @options[:sanitize]
  end

  private

  def convert_to_markup(bb_code)
    parser.parse("\n\n" + bb_code + "\n\n").send("to_#{to_markup}".to_sym)
  end

  def self.load_grammar
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
  end
end
