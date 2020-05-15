$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '../lib'))

require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'lorax'
require 'rbbcode'

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

class RbbCode
  module StringAssertions
    # Takes two strings. Checks if they represent identical DOMs.
    def html_eql?(html1, html2)
      doc1 = Nokogiri.HTML(html1)
      doc2 = Nokogiri.HTML(html2)
      Lorax::Signature.new(doc1.root).signature == Lorax::Signature.new(doc2.root).signature
    end

    def assert_html(expected_string, actual_string, message = nil)
      assert(
        html_eql?(expected_string, actual_string),
        message || "Output not correct. Expected:\n\n#{expected_string.inspect}\n\nGot:\n\n#{actual_string.inspect}"
      )
    end

    def assert_converts_to(expected_html, bb_code, rbbcode_options = {}, message = nil)
      actual_html = RbbCode.new(rbbcode_options).convert(bb_code)
      assert_html(expected_html, actual_html)
    end
  end
end
