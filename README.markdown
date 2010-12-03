About RbbCode
=============

RbbCode is a customizable Ruby library for parsing BB Code originally developed by Jarret (https://github.com/jarrett/rbbcode).

RbbCode validates and cleans input. It supports customizable schemas so you can set rules about what tags are allowed where. The default rules are designed to ensure valid HTML output.

Example usage:

	require 'rubygems'
	require 'rbbcode'

	bb_code = 'This is [b]bold[/b] text'
	parser = RbbCode::Parser.new
	html = parser.parse(bb_code)
	# => '<p>This is <strong>bold</strong> text</p>'

Customizing
===========

You can customize RbbCode by subclassing HtmlMaker and/or by passing configuration directives to a Schema object.

HtmlMaker can be extended by adding methods like this:

	class MyHtmlMaker < RbbCode::HtmlMaker
		def html_from_TAGNAME_tag(node)
			# ...
		end
	end

...where TAGNAME should be replaced with the name of the tag. The method should accept an RbbCode::TagNode and return HTML as a string. (See tree_maker.rb for the definition of RbbCode::TagNode.) Anytime the parser encounters the specified tag, it will call your method and insert the returned HTML into the output.

Now you just have to tell the Parser object to use an instance of your custom subclass instead of the default HtmlMaker:

	my_html_maker = MyHtmlMaker.new
	parser = RbbCode::Parser.new(:html_maker => my_html_maker)

RbbCode removes invalid markup by comparing the input against a Schema object. The Schema is much like a DTD in XML. You can set your own rules and change the default ones by calling configuration methods on a Schema instance. Look at Schema#use_defaults in schema.rb for examples.

Normally, RbbCode instantiates Schema behind the scenes, but if you want to customize it, you'll have to instantiate it yourself and pass the instance to the Parser object:

	schema = RbbCode::Schema.new
	schema.tag('quote').may_not_be_nested # Or whatever other configuration methods you want to call
	parser = RbbCode::Parser.new(:schema => schema)

Unicode Support
===============

UTF-8 compatibility is a high priority for this project. RbbCode aims to be fully compatible with UTF-8, but not with other multibyte encodings. As of the most recent release, UTF-8 support has been tested to a limited extent. It is possible that there are some hidden gotchas. Please report any bugs you may find.

RbbCode does not use any Unicode-aware string classes or methods. Instead, it relies on the fact that BBCode control characters are all in the ASCII range (0x00-0x7F). Since bytes in that range are not allowed as part of multibyte characters, the parser should not mistake a single byte in a multibyte character for a control character. This approach does mean that multibyte characters will be temporarily split up in the RbbCode internals. But in theory, this should be of no consequence, because they should always be correctly reassembled in the output. Please submit a bug report if this is not the case.

BBCode Syntax
=================

As of this writing, there is no official BBCode standard. There are reference implementations, but they differ quite substantially. Wikipedia seemed like the only source with any claim to being canonical, so I followed its examples. The Wikipedia article is at:

http://en.wikipedia.org/wiki/BBCode

From that, I extracted some rules for "common" BBCode syntax. Here are the rules.

Text gets wrapped in `<p>` tags unless it's marked up as some other block-level element such as a list. A single line break becomes a `<br/>`. Two line breaks mark the end of a paragraph, thus a closing `</p>` and possibly an opening `<p>`.

Tags must be in one of the following forms:

	[tagname]Text[/tagname]
	[tagname=value]Text[/tagname]

As you can infer from the second example, RbbCode does not support attributes like in HTML and XML. Rather, a tag can have a single "value," which is similar to an anonymous attribute. This is how [url] and [img] tags work, for example.

RbbCode does not support all the tags listed on Wikpedia out of the box, and probably never will. However, you can easily add support for as many tags as you want.

In order to support inline BBCode tags like smileys I added the following syntax:
    [:tagname]
  
These tags do not need to be closed. For HTML generation the method html_from_tagname_tag(node) is called, as usual.

XSS Prevention
==============

Preventing XSS is one of the top priorities for RbbCode. For tags, RbbCode uses a whitelist. However, URLs can contain JavaScript, and it is not possible to construct a URL whitelist. Therefore, when parsing tags like [url] and [img], RbbCode has to use a blacklist. If you find a vulnerability there, please submit a bug report immediately.

RbbCode sanitizes its URLs in two ways. First, it prepends "http://" to any URL that doesn't have a well-formed protocol. "javascript:" is not a well-formed protocol, because it lacks the two slashes. "javascript://" should not execute. Second, RbbCode hex-encodes various permutations of the word "JavaScript." These two precautions will *hopefully* be enough to prevent browsers executing scripts in URLs, but I can't be sure, because there are a lot of browsers out there.

Also, by enforcing valid XHTML, RbbCode should prevent users breaking your layouts with unclosed tags. Submit a bug report if it doesn't.

Bug Reports
===========

This project is maintained, but bugs sometimes take a few weeks to get fixed. If you find a bug, please take the following steps. Doing so will save me effort and thus greatly increase the chance of the bug being fixed in a timely manner.

1. Make sure it's a bug and not a feature request. See below for details.
2. Write a failing spec. This project uses RSpec. If you don't know how to use it and don't care to learn, then just create a script that produces bad output. Be sure to make it clear what you think the correct output should be. (Don't just say "the output is wrong.") Provide the *shortest* possible input that demonstrates the bug. For example, "Foo bar" is better dummy text than "Mary had a little lamb whose fleece was white as snow." Don't include extra markup that isn't necessary to trigger the bug.
3. Open an issue on Github and paste in your spec or sample script. This is preferred over sending a message.

Feature Requests vs Bugs
========================

Examples of bugs:

- Executable JavaScript appears in the output
- The output is not a valid XHTML fragment
- RbbCode fails to support common BBCode syntax, as exemplified in http://en.wikipedia.org/wiki/BBCode
- UTF-8 messes up, or the output is otherwise mangled
- Any of the specs fail

Example of feature requests:

- You want support for more tags. RbbCode lets you define your own tags. So the absence of, say, the "color" tag in the default parser is not a bug
- You want to support uncommon BBCode syntax, i.e. something you wouldn't see on http://en.wikipedia.org/wiki/BBCode

Do not open an issue for a feature request. Just send a message on Github.

Installation
============

	gem install rbbcode

If that doesn't work, it's probably because RbbCode is hosted on Gemcutter, and your computer doesn't know about Gemcutter yet. To fix that:

	gem install gemcutter
	gem tumble
