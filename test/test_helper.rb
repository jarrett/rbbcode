$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '../lib'))

require 'minitest/unit'
require 'turn/autorun'
require 'lorax'
require 'rbbcode'

class RbbCode
  module HTMLAssertions
    # Takes two strings. Checks if they represent identical DOMs.
    def html_eql?(html1, html2)
      doc1 = Nokogiri.HTML(html1)
      doc2 = Nokogiri.HTML(html2)
      Lorax::Signature.new(doc1.root).signature == Lorax::Signature.new(doc2.root).signature
    end
    
    def assert_html(expected_html, actual_html, message = nil)
      assert(
        html_eql?(expected_html, actual_html),
        message || "HTML output not correct. Expected:\n\n#{expected_html}\n\nGot:\n\n#{actual_html}"
      )
    end
    
    def assert_converts_to(expected_html, bb_code, rbbcode_options = {}, message = nil)
      actual_html = RbbCode.new(rbbcode_options).convert(bb_code)
      assert_html(expected_html, actual_html)
    end
  end
end