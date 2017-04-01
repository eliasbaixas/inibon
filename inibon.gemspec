$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "inibon/iniversion"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "inibon"
  s.version     = Inibon::VERSION
  s.authors     = ["Elias Baixas"]
  s.email       = ["elias.baixas@gmail.com"]
  s.homepage    = "http://www.nowhere.com"
  s.summary     = "Summary of Inibon."
  s.description = "Description of Inibon."
  s.license     = "none"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]

  s.add_dependency "will_paginate-bootstrap", "~> 1.0.1"
  s.add_dependency "rails", ">= 4.2.0"
  s.add_dependency "ancestry", "~> 2.1.0"
  s.add_dependency "statux", "~> 0.0.1"

  s.add_development_dependency "pg"
end
