# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-mysql-appender"
  spec.version       = "0.0.1"
  spec.authors       = ["tsuyoshi_terasaki"]
  spec.email         = ["tsuyoshi_terasaki@realworld.jp"]

  spec.summary       = %q{Fluentd input plugin to track insert event from MySQL database server.}
  spec.description   = %q{Simple incremental id's insert.}
  spec.homepage      = "https://github.com/rw-hub/fluent-plugin-mysql-appender"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "mysql2"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

end
