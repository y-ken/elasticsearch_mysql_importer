# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elasticsearch_mysql_importer/version'

Gem::Specification.new do |spec|
  spec.name          = "elasticsearch_mysql_importer"
  spec.version       = ElasticsearchMysqlImporter::VERSION
  spec.authors       = ["Kentaro Yoshida"]
  spec.email         = ["y.ken.studio@gmail.com"]
  spec.summary       = %q{bulk import file generator as well as nested document from MySQL for elasticsearch bulk api}
  spec.homepage      = "https://github.com/y-ken/elasticsearch_mysql_importer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "mysql2"
  spec.add_runtime_dependency "yajl-ruby"
end
