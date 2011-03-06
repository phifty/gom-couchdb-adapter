
module GOM::Storage::CouchDB

  autoload :Adapter, File.join(File.dirname(__FILE__), "couchdb", "adapter")
  autoload :Collection, File.join(File.dirname(__FILE__), "couchdb", "collection")
  autoload :Counter, File.join(File.dirname(__FILE__), "couchdb", "counter")
  autoload :Fetcher, File.join(File.dirname(__FILE__), "couchdb", "fetcher")
  autoload :Draft, File.join(File.dirname(__FILE__), "couchdb", "draft")
  autoload :Saver, File.join(File.dirname(__FILE__), "couchdb", "saver")
  autoload :Remover, File.join(File.dirname(__FILE__), "couchdb", "remover")
  autoload :View, File.join(File.dirname(__FILE__), "couchdb", "view")

end
