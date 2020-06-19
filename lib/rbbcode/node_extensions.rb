class RbbCode
  module Attributes
    # Strips any number of double quotes from the beginning and end of the string.
    def strip_quotes(str)
      str.sub(/^"+/, '').sub(/"+$/, '')
    end
  end
  
  module RecursiveConversion
    def recursively_convert(node, output_method, depth = 0)
      if node.terminal?
        if node.respond_to?(output_method)
          # This is a terminal node with a custom implementation of the output
          # method (e.g. #to_html).
          node.send(output_method)
        else
          # This is a terminal node without a custom implementation of the
          # output method. If the node consists solely of whitespace, emit the
          # empty string. Otherwise, emit the node's text value.
          node.text_value.match(/^[\n\t]+$/) ? '' : node.text_value
        end
      else
        if node.respond_to?(output_method)
          # This is a non-terminal node with a custom implementation of the
          # output method.
          node.send(output_method)
        else
          # This is a non-terminal node without a custom implementation of the
          # output method. Convert all its child nodes and concatenate the results.
          node.elements.collect do |sub_node|
            recursively_convert(sub_node, output_method, depth + 1)
          end.join
        end
      end
    end
  end
  
  module DocumentNode
    def to_html
      contents.elements.collect { |p| p.to_html }.join
    end

    def to_markdown
      contents.elements.collect { |p| p.to_markdown }.join.sub(/\n+$/, '')
    end
  end
  
  module ParagraphNode
    include RecursiveConversion
    
    def to_html
      # Convert all child nodes, concatenate the results,
      # and wrap the concatenated HTML in <p> tags.
      html = elements.collect do |node|
        recursively_convert(node, :to_html)
      end.join
      "\n<p>" + html + "</p>\n"
    end

    def to_markdown
      # Convert all child nodes, concatenate the results,
      # and append newline characters.
      markdown = elements.collect do |node|
        recursively_convert(node, :to_markdown)
      end.join
      markdown + "\n\n"
    end
  end
  
  module BlockquoteNode
    include RecursiveConversion

    def to_html
      # Detect paragraph breaks and wrap the result in <blockquote> tags.
      paragraphs = []
      cur_para = ''
      lines.elements.each do |line|
        inner = recursively_convert(line, :to_html)
        unless inner.blank?
          cur_para << inner
          if line.post_breaks == 1
            cur_para << ' '
          elsif line.post_breaks >= 2
            paragraphs << cur_para
            cur_para = ''
          end
        end
      end
      unless cur_para.blank?
        paragraphs << cur_para
      end
      inner = paragraphs.map { |str| "<p>#{str}</p>" }.join("\n")
      "\n<blockquote>" + inner + "</blockquote>\n"
    end

    def to_markdown
      # Add a > character per line, preserving linebreaks as they are in the source.
      '> ' + lines.elements.inject('') do |output, line|
        inner_markdown = recursively_convert(line.contents, :to_markdown)
        output + inner_markdown + ("\n> " * line.post_breaks)
      end
    end
  end
  
  module BlockquoteLineNode
    # Returns the number of line breaks after this line. May be zero for the final
    # line, since there doesn't have to be a break before [/quote].
    def post_breaks
      breaks.elements.length
    end
  end

  module ListNode
    include RecursiveConversion
    
    def to_html
      # Convert the :contents child node (defined in the .treetop file)
      # and wrap the result in <ul> tags.
      "\n<ul>" + recursively_convert(contents, :to_html) + "</ul>\n"
    end

    def to_markdown
      # Convert the :contents child node (defined in the .treetop file).
      # Unlike with HTML, no outer markup needed.
      recursively_convert(contents, :to_markdown).lstrip
    end
  end
  
  module ListItemNode
    include RecursiveConversion
    
    def to_html
      # Convert the :contents child node (defined in the .treetop file)
      # and wrap the result in <li> tags.
      "\n<li>" + recursively_convert(contents, :to_html) + "</li>\n"
    end

    def to_markdown
      # Convert the :contents child node (defined in the .treetop file)
      # and add * characters.
      "* " + recursively_convert(contents, :to_html) + "\n"
    end
  end
  
  # You won't find this module in the .treetop file. Instead, it's effectively a specialization
  # of TagNode, which calls to ImgTagNode when processing an img tag. (However, one of the
  # child nodes used here, :url, is indeed defined in the .treetop file.)
  module URLTagNode
    include Attributes
    
    def url_to_html
      # The :url child node (defined in the .treetop file) may or may not exist,
      # depending on how the link is formatted in the BBCode source.
      if respond_to?(:url) and respond_to?(:text)
        # This is a URL tag formatted like [url=http://example.com]Example[/url].
        '<a href="' + strip_quotes(url.text_value) + '">' + text.text_value + '</a>'
      else
        # This is a URL tag formatted like [url]http://example.com[/url].
        '<a href="' + inner_bbcode + '">' + inner_bbcode + '</a>'
      end
    end

    def url_to_markdown
      if respond_to?(:url) and respond_to?(:text)
        # This is a URL tag formatted like [url=http://example.com]Example[/url].
        '[' + text.text_value + '](' + strip_quotes(url.text_value) + ')'
      else
        # This is a URL tag formatted like [url]http://example.com[/url].
        '[' + inner_bbcode + '](' + inner_bbcode + ')'
      end
    end
  end
  
  # You won't find this module in the .treetop file. Instead, it's effectively a specialization
  # of TagNode, which calls to ImgTagNode when processing an img tag.
  module ImgTagNode
    def img_to_html
      '<img src="' + inner_bbcode + '" alt="Image"/>'
    end

    def img_to_markdown
      "![Image](#{inner_bbcode})"
    end
  end

  module UTagNode
    def u_to_markdown
      # Underlining is unsupported in Markdown. So we just ignore [u] tags.
      inner_bbcode
    end
  end
  
  module TagNode
    include RecursiveConversion
    
    # For each tag name, we can either: (a) map to a simple HTML tag or Markdown character, or
    # (b) invoke a separate Ruby module for more advanced logic.
    TAG_MAPPINGS = {
      html: {'b' => 'strong', 'i' => 'em', 'u' => 'u', 'url' => URLTagNode, 'img' => ImgTagNode},
      markdown: {'b' => '**', 'i' => '*', 'u' => UTagNode, 'url' => URLTagNode, 'img' => ImgTagNode}
    }
    
    def contents
      # The first element is the opening tag, the second is everything inside,
      # and the third is the closing tag.
      elements[1] 
    end
    
    def tag_name
      elements.first.text_value.slice(1..-2).downcase
    end
    
    def inner_bbcode
      contents.elements.collect { |e| e.text_value }.join
    end
    
    def inner_html
      contents.elements.collect do |node|
        recursively_convert(node, :to_html)
      end.join
    end

    def inner_markdown
      contents.elements.collect do |node|
        recursively_convert(node, :to_markdown)
      end.join
    end

    def wrap_html(t)
      "<#{t}>" + inner_html + "</#{t}>"
    end

    def wrap_markdown(t)
      t + inner_markdown + t
    end

    def convert(output_format)
      # Consult TAG_MAPPINGS to decide how to process this type of tag.
      t = TAG_MAPPINGS[output_format][tag_name]
      if t.nil?
        raise "No tag mapping found for #{tag_name}"
      elsif t.is_a?(Module)
        # This type of tag requires more than just a simple mapping from one tag name
        # to another. So we invoke a separate Ruby module.
        extend(t)
        send("#{tag_name}_to_#{output_format}")
        # Thus, if our tag_name is"url, and TAG_MAPPINGS points us to URLTagNode,
        # that module must define url_to_html.
      else
        # For this type of tag, a simple mapping from the tag name to a string (such as
        # <i>) suffices.
        send("wrap_#{output_format}", t)
      end
    end
    
    def to_html
      convert :html
    end

    def to_markdown
      convert :markdown
    end
  end
  
  module SingleBreakNode
    def to_html
      '<br/>'
    end
  end
  
  module LiteralTextNode
    def to_html
      text_value
    end

    def to_markdown
      text_value
    end
  end
end