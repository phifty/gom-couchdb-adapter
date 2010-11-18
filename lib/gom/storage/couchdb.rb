
module GOM

  module Storage

    module CouchDB

      autoload :Adapter, File.join(File.dirname(__FILE__), "couchdb", "adapter")
      autoload :Fetcher, File.join(File.dirname(__FILE__), "couchdb", "fetcher")
      autoload :Saver, File.join(File.dirname(__FILE__), "couchdb", "saver")
      autoload :Remover, File.join(File.dirname(__FILE__), "couchdb", "remover")

    end

  end

end
