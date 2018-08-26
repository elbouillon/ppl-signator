# -*- encoding: utf-8 -*-
# stub: cells 4.1.7 ruby lib

Gem::Specification.new do |s|
  s.name = "cells".freeze
  s.version = "4.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nick Sutterer".freeze]
  s.date = "2017-05-05"
  s.description = "View Models for Ruby and Rails, replacing helpers and partials while giving you a clean view architecture with proper encapsulation.".freeze
  s.email = ["apotonick@gmail.com".freeze]
  s.homepage = "https://github.com/apotonick/cells".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "View Models for Ruby and Rails.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<uber>.freeze, ["< 0.2.0"])
      s.add_runtime_dependency(%q<declarative-option>.freeze, ["< 0.2.0"])
      s.add_runtime_dependency(%q<declarative-builder>.freeze, ["< 0.2.0"])
      s.add_runtime_dependency(%q<tilt>.freeze, ["< 3", ">= 1.4"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_development_dependency(%q<cells-erb>.freeze, [">= 0.0.4"])
    else
      s.add_dependency(%q<uber>.freeze, ["< 0.2.0"])
      s.add_dependency(%q<declarative-option>.freeze, ["< 0.2.0"])
      s.add_dependency(%q<declarative-builder>.freeze, ["< 0.2.0"])
      s.add_dependency(%q<tilt>.freeze, ["< 3", ">= 1.4"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_dependency(%q<cells-erb>.freeze, [">= 0.0.4"])
    end
  else
    s.add_dependency(%q<uber>.freeze, ["< 0.2.0"])
    s.add_dependency(%q<declarative-option>.freeze, ["< 0.2.0"])
    s.add_dependency(%q<declarative-builder>.freeze, ["< 0.2.0"])
    s.add_dependency(%q<tilt>.freeze, ["< 3", ">= 1.4"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<capybara>.freeze, [">= 0"])
    s.add_dependency(%q<cells-erb>.freeze, [">= 0.0.4"])
  end
end
