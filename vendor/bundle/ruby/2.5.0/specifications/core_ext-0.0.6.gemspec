# -*- encoding: utf-8 -*-
# stub: core_ext 0.0.6 ruby lib

Gem::Specification.new do |s|
  s.name = "core_ext".freeze
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Rodrigo Panachi".freeze]
  s.date = "2016-03-04"
  s.description = "Utility classes and Ruby extensions for non Rails projects".freeze
  s.email = ["rpanachi@gmail.com".freeze]
  s.homepage = "http://github.com/rpanachi/core_ext".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--encoding".freeze, "UTF-8".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "ActiveSupport's core_ext for non Rails projects".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.1"])
      s.add_runtime_dependency(%q<bigdecimal>.freeze, ["~> 1.2"])
      s.add_runtime_dependency(%q<builder>.freeze, ["~> 3.2"])
      s.add_runtime_dependency(%q<i18n>.freeze, ["~> 0.7"])
      s.add_runtime_dependency(%q<json>.freeze, [">= 1.7.7", "~> 1.7"])
      s.add_runtime_dependency(%q<tzinfo>.freeze, ["~> 1.1"])
      s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<method_source>.freeze, ["~> 0.8"])
    else
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.1"])
      s.add_dependency(%q<bigdecimal>.freeze, ["~> 1.2"])
      s.add_dependency(%q<builder>.freeze, ["~> 3.2"])
      s.add_dependency(%q<i18n>.freeze, ["~> 0.7"])
      s.add_dependency(%q<json>.freeze, [">= 1.7.7", "~> 1.7"])
      s.add_dependency(%q<tzinfo>.freeze, ["~> 1.1"])
      s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
      s.add_dependency(%q<method_source>.freeze, ["~> 0.8"])
    end
  else
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.1"])
    s.add_dependency(%q<bigdecimal>.freeze, ["~> 1.2"])
    s.add_dependency(%q<builder>.freeze, ["~> 3.2"])
    s.add_dependency(%q<i18n>.freeze, ["~> 0.7"])
    s.add_dependency(%q<json>.freeze, [">= 1.7.7", "~> 1.7"])
    s.add_dependency(%q<tzinfo>.freeze, ["~> 1.1"])
    s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
    s.add_dependency(%q<method_source>.freeze, ["~> 0.8"])
  end
end
