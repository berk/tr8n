$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tr8n/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tr8n"
  s.version     = Tr8n::VERSION
  s.authors     = ["Michael Berkovich"]
  s.email       = ["theiceberk@gmail.com"]
  s.homepage    = "https://github.com/berk/will_filter"
  s.summary     = "Crowd-sourced translation engine for Rails."
  s.description = "Crowd-sourced translation and localization engine for Rails."

  s.rubyforge_project = 'tr8n'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = ['README.rdoc']
  s.require_paths = ['lib']

  s.licenses = ['MIT']
  
  s.add_dependency 'rails', ['>= 3.1.0']
  s.add_dependency 'will_filter', ['>= 3.1.2']
  s.add_dependency 'kaminari', ['>= 0']
  s.add_dependency 'sass', ['>= 0']
  s.add_dependency 'coffee-script', ['>= 0']
  s.add_development_dependency 'bundler', ['>= 1.0.0']
  s.add_development_dependency 'sqlite3', ['>= 0']
  s.add_development_dependency 'rspec', ['>= 0']
  s.add_development_dependency 'rspec-rails', ['>= 0']
  s.add_development_dependency 'factory_girl', ['>= 0']
  s.add_development_dependency 'rr', ['>= 0']
  s.add_development_dependency 'steak', ['>= 0']
  s.add_development_dependency 'capybara', ['>= 0']
  s.add_development_dependency 'database_cleaner', ['>= 0']
end
