# -*- encoding: utf-8 -*-
require File.expand_path('../lib/que_mailer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Robert Prehn"]
  gem.email         = ["robert@revelry.co"]
  gem.description   = %q{Asynchronous mail delivery using que}
  gem.summary       = %q{Using Que to delivery mail asynchronously}
  gem.homepage      = "http://github.com/prehnra/que-mailer"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "que_mailer"
  gem.require_paths = ["lib"]
  gem.version       = Que::Mailer::VERSION

  gem.add_dependency("activesupport", ">= 4.0")
  gem.add_dependency("actionmailer", ">= 4.0")
  gem.add_dependency("que", "0.5.0")
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec')
end