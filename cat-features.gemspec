lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cat-features/version"

Gem::Specification.new do |spec|
  spec.name          = "cat-features"
  spec.version       = CatFeatures::VERSION
  spec.authors       = ["Unact"]
  spec.email         = "it@unact.ru"

  spec.summary       = "CatFeatures"
  spec.description   = "CatFeatures"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 5.2", "< 6"
  spec.add_dependency "composite_primary_keys", "~> 11.0.0"
  spec.add_dependency "acts_as_singleton", "~> 0.0.8"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "database_cleaner"
end
