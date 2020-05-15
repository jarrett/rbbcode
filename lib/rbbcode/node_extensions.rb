class RbbCode
  module Attributes
    # Strips any number of double quotes from the beginning and end of the string.
    def strip_quotes(str)
      str.sub(/^"+/, '').sub(/"+$/, '')
    end
  end

  module RecursiveConversion
    def recursively_convert(node, to_markup, depth = 0)
      if node.terminal?
        if node.respond_to?(to_markup)
          # This is a non-terminal node with a custom #to_html implementation.
          node.send(to_markup)
        else
          # This is a terminal node without a custom #to_html implementation.
          # If the node consists solely of whitespace, emit the empty string.
          # Otherwise, emit the node's text value.
          node.text_value.match(/^[\r\n\t]+$/) ? '' : node.text_value
        end
      else
        if node.respond_to?(to_markup)
          # This is a non-terminal node with a custom #to_html implementation.
          node.send(to_markup)
        else
          # This is a non-terminal node without a custom #to_html implementation.
          # Convert all its child nodes and concatenate the results.
          node.elements.collect do |sub_node|
            recursively_convert(sub_node, to_markup, depth + 1)
          end.join
        end
      end
    end
  end

  module DocumentNode
    def to_html
      paragraphs(&:to_html)
    end

    def to_markdown
      paragraphs(&:to_html)
    end

    def paragraphs
      contents.elements.collect do |paragraph|
        yield(paragraph)
      end.join
    end
  end

  module ParagraphNode
    include RecursiveConversion

    def to_html
      # Convert all child nodes and concatenate the results.
      # Wrap the concatenated HTML in <p> tags.
      "\n<p>" + markup(__method__) + "</p>\n"
    end

    def to_markdown
      markup(__method__) + "\n\n"
    end

    def markup(to_markup)
      elements.collect do |node|
        recursively_convert(node, to_markup)
      end.join
    end
  end

  module BlockquoteNode
    include RecursiveConversion

    def to_html
      # Convert the :contents child node (defined in the .treetop file)
      # and wrap the result in <blockquote> tags.
      "\n<blockquote>" + recursively_convert(contents, __method__) + "</blockquote>\n"
    end

    def to_markdown
      recursively_convert(contents, __method__) + "\n"
    end
  end

  module QuoteItemNode
    include RecursiveConversion

    def to_markdown
      "\n> " + recursively_convert(contents, __method__) + "\n"
    end
  end

  module ListNode
    include RecursiveConversion

    def to_html
      "\n<ul>" + recursively_convert(contents, __method__) + "</ul>\n"
    end

    def to_markdown
      recursively_convert(contents, __method__) + "\n"
    end
  end

  module ListItemNode
    include RecursiveConversion

    def to_html
      # Convert the :contents child node (defined in the .treetop file)
      # and wrap the result in <ul> tags.
      "\n<li>" + recursively_convert(contents, __method__) + "</li>\n"
    end

    def to_markdown
      # Convert the :contents child node (defined in the .treetop file)
      # and wrap the result in <ul> tags.
      "\n*" + recursively_convert(contents, __method__)
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
        # A URL tag formatted like [url=http://example.com]Example[/url]
        '[' + text.text_value + '](' + strip_quotes(url.text_value) + ')'
      else
        # A URL tag formatted like [url]http://example.com[/url]
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
      '![Image](' + inner_bbcode + ')'
    end
  end

  module StrongTagNode
    def b_to_markdown
      '**' + inner_bbcode + '**'
    end
  end

  module ItalicTagNode
    def i_to_markdown
      '*' + inner_bbcode + '*'
    end
  end

  module TagNode
    include RecursiveConversion

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

    def inner_html(to_markup)
      contents.elements.collect do |node|
        recursively_convert(node, to_markup)
      end.join
    end

    def to_html
      # Consult TAG_MAPPINGS to decide how to process this type of tag.
      t = tag_mappings(__method__)[tag_name]
      if t.nil?
        raise "No tag mapping found for #{tag_name}"
      elsif t.is_a?(Module)
        extend(t)
        send("#{tag_name}_#{__method__}")
        # Thus, if our tag_name is"url, and TAG_MAPPINGS points us to URLTagNode,
        # that module must define url_to_html
      else
        "<#{t}>" + inner_html(__method__) + "</#{t}>"
      end
    end

    def to_markdown
      # Consult TAG_MAPPINGS to decide how to process this type of tag.
      t = tag_mappings(__method__)[tag_name]
      if t.nil?
        raise "No tag mapping found for #{tag_name}"
      elsif t.is_a?(Module)
        # This type of tag requires more than just a simple mapping from one tag name
        # to another. So we invoke a separate Ruby module.
        extend(t)
        send("#{tag_name}_#{__method__}")
        # Thus, if our tag_name is"url, and TAG_MAPPINGS points us to URLTagNode,
        # that module must define url_to_markdown.
      else
        # For this type of tag, a simple mapping from one tag name to another suffices.
        "<#{t}>" + inner_html + "</#{t}>"
      end
    end

    # For each tag name, we can either: (a) map to a simple HTML tag, or (b) invoke
    # a separate Ruby module for more advanced logic.
    def tag_mappings(to_markup)
      if to_markup == :to_markdown
        {
          'b' => StrongTagNode,
          'i' => ItalicTagNode,
          'u' => 'u',
          'url' => URLTagNode,
          'img' => ImgTagNode
        }
      else
        {
          'b' => 'strong',
          'i' => 'em',
          'u' => 'u',
          'url' => URLTagNode,
          'img' => ImgTagNode
        }
      end
    end
  end

  module SingleBreakNode
    def to_html
      '<br/>'
    end

    def to_markdown
      '  '
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
