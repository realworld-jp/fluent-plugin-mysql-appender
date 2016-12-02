# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-mysql-appender"
  spec.version       = "0.4.5"
  spec.authors       = ["TERASAKI Tsuyoshi"]
  spec.email         = ["tsuyoshi_terasaki@realworld.jp"]

  spec.summary       = %q{Fluentd input plugin to insert from MySQL database server.}
  spec.description   = %q{Simple incremental id's insert.}
  spec.homepage      = "https://github.com/realworld-jp/fluent-plugin-mysql-appender"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($\)
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "mysql2"
  spec.add_runtime_dependency "td"
  spec.add_runtime_dependency "td-client"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "test-unit-rr"
end
