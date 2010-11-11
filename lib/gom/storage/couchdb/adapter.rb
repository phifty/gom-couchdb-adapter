
module GOM

  module Storage

    module CouchDB

      # The couchdb storage adapter
      class Adapter < GOM::Storage::Adapter

        def initialize(configuration)
          super configuration
        end

        def fetch(id)

        end

        def store(object, storage_name = nil)

        end

        def remove(object)

        end

      end

    end

  end

end
