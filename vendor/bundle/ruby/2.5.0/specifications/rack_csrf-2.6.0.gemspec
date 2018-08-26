# -*- encoding: utf-8 -*-
# stub: rack_csrf 2.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rack_csrf".freeze
  s.version = "2.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Emanuele Vicentini".freeze]
  s.date = "2016-12-31"
  s.description = "Anti-CSRF Rack middleware".freeze
  s.email = ["emanuele.vicentini@gmail.com".freeze]
  s.extra_rdoc_files = ["LICENSE.rdoc".freeze, "README.rdoc".freeze]
  s.files = ["LICENSE.rdoc".freeze, "README.rdoc".freeze]
  s.homepage = "https://github.com/baldowl/rack_csrf".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--line-numbers".freeze, "--inline-source".freeze, "--title".freeze, "Rack::Csrf 2.6.0".freeze, "--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Anti-CSRF Rack middleware".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>.freeze, [">= 1.1.0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 1.0.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<cucumber>.freeze, ["~> 2.4"])
      s.add_development_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 2.4.2"])
      s.add_development_dependency(%q<git>.freeze, [">= 1.2.5"])
    else
      s.add_dependency(%q<rack>.freeze, [">= 1.1.0"])
      s.add_dependency(%q<bundler>.freeze, [">= 1.0.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<cucumber>.freeze, ["~> 2.4"])
      s.add_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rdoc>.freeze, [">= 2.4.2"])
      s.add_dependency(%q<git>.freeze, [">= 1.2.5"])
    end
  else
    s.add_dependency(%q<rack>.freeze, [">= 1.1.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.0.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<cucumber>.freeze, ["~> 2.4"])
    s.add_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 2.4.2"])
    s.add_dependency(%q<git>.freeze, [">= 1.2.5"])
  end
end
