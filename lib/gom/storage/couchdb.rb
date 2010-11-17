
module GOM

  module Storage

    module CouchDB

      autoload :Adapter, File.join(File.dirname(__FILE__), "couchdb", "adapter")
      autoload :Fetcher, File.join(File.dirname(__FILE__), "couchdb", "fetcher")

    end

  end

end
