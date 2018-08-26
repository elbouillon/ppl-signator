# -*- encoding: utf-8 -*-
# stub: formular 0.2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "formular".freeze
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nick Sutterer".freeze, "Fran Worley".freeze]
  s.bindir = "exe".freeze
  s.date = "2017-12-08"
  s.description = "Customizable, fast form builder based on Cells. Framework-agnostic.".freeze
  s.email = ["apotonick@gmail.com".freeze, "frances@safetytoolbox.co.uk".freeze]
  s.homepage = "http://trailblazer.to/gems/formular.html".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Form builder based on Cells. Fast, Furious, and Framework-Agnostic.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<declarative>.freeze, ["~> 0.0.4"])
      s.add_runtime_dependency(%q<uber>.freeze, ["< 0.2.0", ">= 0.0.11"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<trailblazer-cells>.freeze, [">= 0"])
      s.add_development_dependency(%q<cells-slim>.freeze, [">= 0"])
      s.add_development_dependency(%q<cells-erb>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest-line>.freeze, [">= 0"])
    else
      s.add_dependency(%q<declarative>.freeze, ["~> 0.0.4"])
      s.add_dependency(%q<uber>.freeze, ["< 0.2.0", ">= 0.0.11"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<trailblazer-cells>.freeze, [">= 0"])
      s.add_dependency(%q<cells-slim>.freeze, [">= 0"])
      s.add_dependency(%q<cells-erb>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<minitest-line>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<declarative>.freeze, ["~> 0.0.4"])
    s.add_dependency(%q<uber>.freeze, ["< 0.2.0", ">= 0.0.11"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<trailblazer-cells>.freeze, [">= 0"])
    s.add_dependency(%q<cells-slim>.freeze, [">= 0"])
    s.add_dependency(%q<cells-erb>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<minitest-line>.freeze, [">= 0"])
  end
end
