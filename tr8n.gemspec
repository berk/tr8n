lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "tr8n"
  gem.version       = IO.read('VERSION')
  gem.authors       = ["Michael Berkovich"]
  gem.email         = ["michael@geni.com"]
  gem.description   = %q{Crowd-sourced translation and localization for Rails}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/berk/tr8n"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
