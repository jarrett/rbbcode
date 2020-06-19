$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '../lib'))

require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'lorax'
require 'uri'
require 'rbbcode'

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

class RbbCode
  module OutputAssertions
    # Takes two strings. Checks if they represent identical DOMs.
    def html_eql?(html1, html2)
      doc1 = Nokogiri.HTML(html1)
      doc2 = Nokogiri.HTML(html2)
      Lorax::Signature.new(doc1.root).signature == Lorax::Signature.new(doc2.root).signature
    end
    
    def assert_output(expected_output, actual_output, output_format, message = nil)
      case output_format
      when :html
        assert(
          html_eql?(expected_output, actual_output),
          (message || 'HTML output not correct.') +
          " Expected:\n\n#{expected_output}\n\nGot:\n\n#{actual_output}"
        )
      when :markdown
        assert(
          expected_output == actual_output,
          (message || 'Markdown output not correct.') +
          " Expected:\n\n\"#{escape_ws(expected_output)}\"\n\nGot:\n\n\"#{escape_ws(actual_output)}\""
        )
      else
        raise ArgumentError, "Unknown output format: #{output_format.inspect}"
      end
    end
    
    def assert_converts_to(expected_output, bb_code, rbbcode_options = {}, message = nil)
      rbbcode = RbbCode.new(rbbcode_options)
      actual_output = rbbcode.convert(bb_code)
      assert_output(expected_output, actual_output, rbbcode.output_format, message)
    end

    def escape_ws(str)
      str.gsub(' ', '_').gsub("\t", '\t')
    end
  end

  module Heredoc
    def heredoc(input)
      lines = input.lines
      unless lines.shift.match(/^[ \t]*\n$/)
        raise ArgumentError, 'Input to #heredoc must begin with blank line'
      end
      unless lines.pop.match(/[ \t]*$/)
        raise ArgumentError, 'Input to #heredoc must end with blank line'
      end
      indent = lines.first.match(/^ */).to_s.length
      pattern = /^#{' ' * indent}/
      lines.map do |line|
        line.sub(pattern, '').chomp
      end.join("\n")
    end
  end
end