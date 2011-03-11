# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "tr8n"
  s.version = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Berkovich"]
  s.email       = %q{michael@geni.com}
  s.homepage    = %q{http://github.com/berk/tr8n}
  s.summary     = %q{Crowd-sourced translation for Rails.}
  s.description = %q{Crowd-sourced translation and localization for Rails}

  s.rubyforge_project = "tr8n"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
