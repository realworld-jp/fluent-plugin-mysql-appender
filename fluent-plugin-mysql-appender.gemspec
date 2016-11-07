# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent/plugin/mysql/appender/version'

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-mysql-appender"
  spec.version       = Fluent::Plugin::Mysql::Appender::VERSION
  spec.authors       = ["tsuyoshi_terasaki"]
  spec.email         = ["tsuyoshi_terasaki@realworld.jp"]

  spec.summary       = %q{Fluentd input plugin to track insert event from MySQL database server.}
  spec.description   = %q{Simple incremental id's insert.}
  spec.homepage      = "https://github.com/rw-hub/fluent-plugin-mysql-appender"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "mysql2"
end
