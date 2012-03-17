# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "stale_if_slow/version"

Gem::Specification.new do |s|
  s.name        = "stale_if_slow"
  s.version     = StaleIfSlow::VERSION
  s.authors     = ["tulios"]
  s.email       = ["ornelas.tulio@gmail.com"]
  s.homepage    = "https://github.com/tulios/stale_if_slow"
  s.summary     = %q{Is a quality assurance tool for methods that access external services or have slow operations that could rely on stale cache in case of problem}
  s.description = %q{Is a quality assurance tool for methods that access external services or have slow operations that could rely on stale cache in case of problem}

  s.required_ruby_version = ">= 1.9.2"
  s.rubyforge_project     = "stale_if_slow"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency "rspec", "~> 2.8.0"
  s.add_development_dependency "ruby-debug19"
  
  s.add_dependency "activesupport", "~> 3.2.2"
end
