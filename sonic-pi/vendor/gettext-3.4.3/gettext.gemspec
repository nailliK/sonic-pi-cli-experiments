# -*- mode: ruby; coding: utf-8 -*-

base_dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(base_dir, "lib"))
require "gettext/version"

Gem::Specification.new do |s|
  s.name = "gettext"
  s.version = GetText::VERSION
  s.summary = 'Gettext is a pure Ruby libary and tools to localize messages.'
  s.description = <<-EOD
Gettext is a GNU gettext-like program for Ruby.
The catalog file(po-file) is same format with GNU gettext.
So you can use GNU gettext tools for maintaining.
  EOD
  s.authors = ["Kouhei Sutou", "Masao Mutoh"]
  s.email = ["kou@clear-code.com", "mutomasa at gmail.com"]
  s.homepage = "https://ruby-gettext.github.io/"
  s.require_paths = ["lib"]
  Dir.chdir(base_dir) do
    s.files = Dir.glob("{locale,bin,data,doc/text,lib,po,samples,src,test}/**/*")
    s.files += ["README.md", "Rakefile", "gettext.gemspec"]
    s.files += [".yardopts"]
    s.executables = Dir.chdir("bin") do
      Dir.glob("*")
    end
    s.test_files = Dir.glob("test/test_*.rb")
  end

  s.required_ruby_version = ">= 2.5.0"

  s.add_runtime_dependency("erubi")
  s.add_runtime_dependency("locale", ">= 2.0.5")
  s.add_runtime_dependency("prime")
  s.add_runtime_dependency("text", ">= 1.3.0")
  s.add_development_dependency("kramdown")
  s.add_development_dependency("racc")
  s.add_development_dependency("rake")
  s.add_development_dependency("red-datasets")
  s.add_development_dependency("test-unit")
  s.add_development_dependency("test-unit-rr")
  s.add_development_dependency("yard")
  s.licenses = ["Ruby", "LGPL-3.0+"]
end
