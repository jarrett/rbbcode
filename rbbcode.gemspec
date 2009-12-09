# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rbbcode}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jarrett Colby"]
  s.date = %q{2009-12-09}
  s.description = %q{RbbCode is a customizable Ruby library for parsing BB Code. RbbCode validates and cleans input. It supports customizable schemas so you can set rules about what tags are allowed where. The default rules are designed to ensure valid HTML output.}
  s.email = %q{jarrett@jarrettcolby.com}
  s.extra_rdoc_files = [
    "README"
  ]
  s.homepage = %q{http://github.com/jarrett/rbbcode}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Ruby BB Code parser}
  s.test_files = [
    "spec/html_maker_spec.rb",
     "spec/node_spec_helper.rb",
     "spec/parser_spec.rb",
     "spec/schema_spec.rb",
     "spec/spec_helper.rb",
     "spec/tree_maker_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
