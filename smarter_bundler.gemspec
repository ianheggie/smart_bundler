# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "smarter_bundler/version"

Gem::Specification.new do |spec|
  spec.name          = "smarter_bundler"
  spec.version       = SmarterBundler::VERSION
  spec.authors       = ["Ian Heggie"]
  spec.email         = ["ian@heggie.biz"]

  spec.summary       = %q{Enhances bundler by adjusting Gemfile when correctable errors are found}
  spec.description   = %q{The smarter_bundle retries installing gems, and if that fails it tries installing an earlier version by adjusting the Gemfile}
  spec.homepage      = "https://github.com/ianheggie/smarter_bundler"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
