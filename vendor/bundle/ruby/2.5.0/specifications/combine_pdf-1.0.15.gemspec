# -*- encoding: utf-8 -*-
# stub: combine_pdf 1.0.15 ruby lib

Gem::Specification.new do |s|
  s.name = "combine_pdf".freeze
  s.version = "1.0.15"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Boaz Segev".freeze]
  s.date = "2018-08-12"
  s.description = "A nifty gem, in pure Ruby, to parse PDF files and combine (merge) them with other PDF files, number the pages, watermark them or stamp them, create tables, add basic text objects etc` (all using the PDF file format).".freeze
  s.email = ["boaz@2be.co.il".freeze]
  s.homepage = "https://github.com/boazsegev/combine_pdf".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Combine, stamp and watermark PDF files in pure Ruby.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ruby-rc4>.freeze, [">= 0.1.5"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
    else
      s.add_dependency(%q<ruby-rc4>.freeze, [">= 0.1.5"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<ruby-rc4>.freeze, [">= 0.1.5"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
  end
end
