$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "inibon/version"

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

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "pg"
end
