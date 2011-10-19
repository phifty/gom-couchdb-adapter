# encoding: utf-8

Gem::Specification.new do |specification|
  specification.name              = "gom-couchdb-adapter"
  specification.version           = "0.5.0"
  specification.date              = "2011-10-19"

  specification.authors           = [ "Philipp Brüll" ]
  specification.email             = "b.phifty@gmail.com"
  specification.homepage          = "http://github.com/phifty/gom-couchdb-adapter"
  specification.rubyforge_project = "gom-couchdb-adapter"

  specification.summary           = "CouchDB storage adapter for the General Object Mapper."
  specification.description       = "CouchDB storage adapter for the General Object Mapper. Current versions of CouchDB are supported."

  specification.has_rdoc          = true
  specification.files             = [ "README.rdoc", "LICENSE", "Rakefile" ] + Dir["lib/**/*"] + Dir["spec/**/*"]
  specification.extra_rdoc_files  = [ "README.rdoc" ]
  specification.require_path      = "lib"

  specification.test_files        = Dir["spec/**/*_spec.rb"]

  specification.add_dependency "gom", ">= 0.5.0"
  specification.add_dependency "couchdb", ">= 0.2.2"

  specification.add_development_dependency "rspec", ">= 2"
  specification.add_development_dependency "reek", ">= 1.2"
end
