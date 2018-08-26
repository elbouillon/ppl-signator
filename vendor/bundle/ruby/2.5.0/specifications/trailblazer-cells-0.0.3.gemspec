# -*- encoding: utf-8 -*-
# stub: trailblazer-cells 0.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "trailblazer-cells".freeze
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nick Sutterer".freeze]
  s.bindir = "exe".freeze
  s.date = "2016-05-25"
  s.description = "Cells that integrate with Trailblazer's file layout.".freeze
  s.email = ["apotonick@gmail.com".freeze]
  s.homepage = "http://trailblazer.to/gems/cells".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Trailblazer's file layout with Cells.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<cells-erb>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<cells>.freeze, ["< 5.0.0", ">= 4.1.0.rc1"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<cells-erb>.freeze, [">= 0"])
      s.add_dependency(%q<cells>.freeze, ["< 5.0.0", ">= 4.1.0.rc1"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<cells-erb>.freeze, [">= 0"])
    s.add_dependency(%q<cells>.freeze, ["< 5.0.0", ">= 4.1.0.rc1"])
  end
end
