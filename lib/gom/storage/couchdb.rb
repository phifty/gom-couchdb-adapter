
module GOM

  module Storage

    module CouchDB

      autoload :Adapter, File.join(File.dirname(__FILE__), "couchdb", "adapter")
      autoload :Collection, File.join(File.dirname(__FILE__), "couchdb", "collection")
      autoload :Fetcher, File.join(File.dirname(__FILE__), "couchdb", "fetcher")
      autoload :ObjectHash, File.join(File.dirname(__FILE__), "couchdb", "object_hash")
      autoload :Saver, File.join(File.dirname(__FILE__), "couchdb", "saver")
      autoload :Remover, File.join(File.dirname(__FILE__), "couchdb", "remover")
      autoload :View, File.join(File.dirname(__FILE__), "couchdb", "view")

    end

  end

end
