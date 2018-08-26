# -*- encoding: utf-8 -*-
# stub: cells-slim 0.0.6 ruby lib

Gem::Specification.new do |s|
  s.name = "cells-slim".freeze
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Abdelkader Boudih".freeze, "Nick Sutterer".freeze]
  s.date = "2018-04-11"
  s.description = "Slim integration for Cells.".freeze
  s.email = ["terminale@gmail.com".freeze, "apotonick@gmail.com".freeze]
  s.homepage = "https://github.com/trailblazer/cells-slim".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Slim integration for Cells.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cells>.freeze, ["< 6.0.0", ">= 4.0.1"])
      s.add_runtime_dependency(%q<slim>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<cells>.freeze, ["< 6.0.0", ">= 4.0.1"])
      s.add_dependency(%q<slim>.freeze, ["~> 3.0"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<cells>.freeze, ["< 6.0.0", ">= 4.0.1"])
    s.add_dependency(%q<slim>.freeze, ["~> 3.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
