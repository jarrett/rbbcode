# RbbCode

## Important notice for users of 0.1.11 or lower

RbbCode has been updated! The new release (1.x.x) is not compatible with the old one (0.1.11). If
you want to upgrade to 1.x.x, you'll need to adjust any calls to RbbCode in your code to match the
new API, as described below.

## About RbbCode

RbbCode converts BBCode to HTML and Markdown. Basic usage:

    RbbCode.new.convert('This is [b]BBCode[/b]')

RbbCode recovers gracefully from invalid markup. Any bad BBCode tags will remain in the output as-is,
i.e. they will not be converted to HTML tags and will be visible to end users. All HTML output is
passed through the [Sanitize](https://github.com/rgrove/sanitize) gem. This protects you against
malicious HTML.

For the curious, the parser is built with Treetop. But you don't need to know anything about Treetop
to use RbbCode.

## Installation

    gem install rbbcode

## Options

The constructor can accept an options hash.

You can set the `:output_format` to either `:html` or `:markdown`. If not specified, `:output_format` defaults
to `:html`.

    RbbCode.new(:output_format => :html)
    RbbCode.new(:output_format => :markdown)

To add emoticon support:

    RbbCode.new(:emoticons => {':)' => 'http://example.com/path/to/your/smiley.png'})
    
You can supply a [Sanitize config hash](https://github.com/rgrove/sanitize#configuration), which will
be passed through verbatim to the Sanitize gem. The default Sanitize config is in
`rbbcode/sanitize.rb`. Usage:

    RbbCode.new(:sanitize_config => my_sanitize_config_hash)
    
You can also turn Sanitize off altogether, but it's not recommended:

    # Probably a bad idea
    RbbCode.new(:sanitize => false)

Sanitization works for HTML output only. If you select a different output format, the `:sanitize`
option will be ignored, and the output won't be sanitized.

## Supported BBCode features

RbbCode supports the following BBCode features:

  * [b]
  * [i]
  * [u]
  * [s]
  * [url]
  * [img]
  * [quote]
  * [list]
  * Emoticons
  
Some BBCode parsers in the wild have more features. This varies from forum to forum. If there's a
certain tag or other feature you'd like to see supported, please open an issue on:

https://github.com/jarrett/rbbcode