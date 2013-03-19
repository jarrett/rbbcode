class RbbCode
  module RecursiveConversion
    def recursively_convert(node, depth = 0)
      if node.terminal?
        if node.respond_to?(:to_html)
          node.to_html
        else
          node.text_value.match(/^[\r\n\t]+$/) ? '' : node.text_value
        end
      else
        if node.respond_to?(:to_html)
          node.to_html
        else
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
      html = elements.collect do |node|
        recursively_convert(node)
      end.join
      "\n<p>" + html + "</p>\n"
    end
  end
  
  module BlockquoteNode
    include RecursiveConversion
    
    def to_html
      "\n<blockquote>" + recursively_convert(contents) + "</blockquote>\n"
    end
  end
  
  module ListNode
    include RecursiveConversion
    
    def to_html
      "\n<ul>" + recursively_convert(contents) + "</ul>\n"
    end
  end
  
  module ListItemNode
    include RecursiveConversion
    
    def to_html
      "\n<li>" + recursively_convert(contents) + "</li>\n"
    end
  end
  
  module URLTagNode
    def url_to_html
      if respond_to?(:url) and respond_to?(:text)
        # A URL tag formatted like [url=http://example.com]Example[/url]
        '<a href="' + url.text_value + '">' + text.text_value + '</a>'
      else
        # A URL tag formatted like [url]http://example.com[/url]
        '<a href="' + inner_bbcode + '">' + inner_bbcode + '</a>'
      end
    end
  end
  
  module ImgTagNode
    def img_to_html
      '<img src="' + inner_bbcode + '" alt="Image"/>'
    end
  end
  
  module ColorTagNode
    def color_to_html
      '<span style="color:' + ident.text_value + ';">' + recursively_convert(text)  + '</span>'
    end
  end
  
  module TagNode
    include RecursiveConversion
    
    TAG_MAPPINGS = { 'b' => 'strong', 'i' => 'em', 'u' => 'u', 'url' => URLTagNode, 'img' => ImgTagNode, 'color' => ColorTagNode }
    
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
      t = TAG_MAPPINGS[tag_name]
      if t.nil?
        raise "No tag mapping found for #{tag_name}"
      elsif t.is_a?(Module)
        extend(t)
        send(tag_name + '_to_html')
        # Thus, if our tag_name is"url, and TAG_MAPPINGS points us to URLTagNode,
        # that module must define url_to_html.
      else
        "<#{t}>" + inner_html + "</#{t}>"
      end
    end
  end
  
  module SingleBreakNode
    def to_html
      '<br/>'
    end
  end
end