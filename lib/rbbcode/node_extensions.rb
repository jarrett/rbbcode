class RbbCode
  module Attributes
    # Strips any number of double quotes from the beginning and end of the string.
    def strip_quotes(str)
      str.sub(/^"+/, '').sub(/"+$/, '')
    end
  end
  
  module RecursiveConversion
    def recursively_convert(node, depth = 0)
      if node.terminal?
        if node.respond_to?(:to_html)
          # This is a terminal node with a custom #to_html implementation.
          node.to_html
        else
          # This is a terminal node without a custom #to_html implementation.
          # If the node consists solely of whitespace, emit the empty string.
          # Otherwise, emit the node's text value.
          node.text_value.match(/^[\r\n\t]+$/) ? '' : node.text_value
        end
      else
        if node.respond_to?(:to_html)
          # This is a non-terminal node with a custom #to_html implementation.
          node.to_html
        else
          # This is a non-terminal node without a custom #to_html implementation.
          # Convert all its child nodes and concatenate the results.
          node.elements.collect do |sub_node|
            recursively_convert(sub_node, depth + 1)
          end.join
        end
      end
    end
  end
  
  module DocumentNode
    def to_html
      contents.elements.collect { |p| p.to_html }.join
    end
  end
  
  module ParagraphNode
    include RecursiveConversion
    
    def to_html
      # Convert all child nodes and concatenate the results.
      # Wrap the concatenated HTML in <p> tags.
      html = elements.collect do |node|
        recursively_convert(node)
      end.join
      "\n<p>" + html + "</p>\n"
    end
  end
  
  module BlockquoteNode
    include RecursiveConversion
    
    def to_html
      # Convert the :contents child node (defined in the .treetop file)
      # and wrap the result in <blockquote> tags.
      "\n<blockquote>" + recursively_convert(contents) + "</blockquote>\n"
    end
  end
  
  module ListNode
    include RecursiveConversion
    
    def to_html
      # Convert the :contents child node (defined in the .treetop file)
      # and wrap the result in <ul> tags.
      "\n<ul>" + recursively_convert(contents) + "</ul>\n"
    end
  end
  
  module ListItemNode
    include RecursiveConversion
    
    def to_html
      # Convert the :contents child node (defined in the .treetop file)
      # and wrap the result in <li> tags.
      "\n<li>" + recursively_convert(contents) + "</li>\n"
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
  end
  
  # You won't find this module in the .treetop file. Instead, it's effectively a specialization
  # of TagNode, which calls to ImgTagNode when processing an img tag.
  module ImgTagNode
    def img_to_html
      '<img src="' + inner_bbcode + '" alt="Image"/>'
    end
  end
  
  module TagNode
    include RecursiveConversion
    
    # For each tag name, we can either: (a) map to a simple HTML tag, or (b) invoke
    # a separate Ruby module for more advanced logic.
    TAG_MAPPINGS = {'b' => 'strong', 'i' => 'em', 'u' => 'u', 'url' => URLTagNode, 'img' => ImgTagNode}
    
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
        recursively_convert(node)
      end.join
    end
    
    def to_html
      # Consult TAG_MAPPINGS to decide how to process this type of tag.
      t = TAG_MAPPINGS[tag_name]
      if t.nil?
        raise "No tag mapping found for #{tag_name}"
      elsif t.is_a?(Module)
        # This type of tag requires more than just a simple mapping from one tag name
        # to another. So we invoke a separate Ruby module.
        extend(t)
        send(tag_name + '_to_html')
        # Thus, if our tag_name is"url, and TAG_MAPPINGS points us to URLTagNode,
        # that module must define url_to_html.
      else
        # For this type of tag, a simple mapping from one tag name to another suffices.
        "<#{t}>" + inner_html + "</#{t}>"
      end
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
  end
end