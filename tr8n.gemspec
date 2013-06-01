$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tr8n/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tr8n"
  s.version     = Tr8n::VERSION
  s.authors     = ["Michael Berkovich"]
  s.email       = ["michael@tr8n.net"]
  s.homepage    = "https://github.com/berk/tr8n"
  s.summary     = "Crowd-sourced translation engine for Rails."
  s.description = "Crowd-sourced translation and localization engine for Rails."

  s.files         = `git ls-files`.split("\n") - Dir.glob("app/javascripts/**/*")
  s.test_files    = `git ls-files -- {test,local,spec,features}/*`.split("\n")
  s.extra_rdoc_files = ['README.rdoc']
  s.require_paths = ['lib']

  s.licenses = ['MIT']
  
  s.add_dependency "rails", '~> 3.2.3'
  s.add_dependency 'will_filter', '~> 3.1.9'
  s.add_dependency 'kaminari', '>= 0'
  s.add_dependency 'sass', '>= 0'
  s.add_dependency 'faraday', '>= 0'
  s.add_dependency 'money', '>= 0'
  s.add_development_dependency 'dalli'
  s.add_development_dependency 'fssm', ['>= 0']
  s.add_development_dependency 'pry', ['>= 0']
  s.add_development_dependency 'bundler', ['>= 1.0.0']
  s.add_development_dependency 'sqlite3', ['>= 0']
  s.add_development_dependency 'rspec', ['>= 0']
  s.add_development_dependency 'rspec-rails', ['>= 2.1.0']
  s.add_development_dependency 'spork', ['>= 0']
  s.add_development_dependency 'watchr', ['>= 0']
  s.add_development_dependency 'rr', ['>= 0']
  s.add_development_dependency 'dalli'
end
