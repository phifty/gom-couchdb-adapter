
module GOM

  module Storage

    module CouchDB

      # The couchdb storage adapter
      class Adapter < GOM::Storage::Adapter

        def setup
          initialize_server
          initialize_database
          setup_database
        end

        def fetch(id)
          fetcher = Fetcher.new @database, id, revisions
          fetcher.perform
          fetcher.object_hash
        end

        def store(object_hash)
          saver = Saver.new @database, object_hash, revisions, configuration.name
          saver.perform
          saver.id
        end

        def remove(id)
          remover = Remover.new @database, id, revisions
          remover.perform
        end

        def revisions
          @revisions ||= { }
        end

        private

        def initialize_server
          @server = ::CouchDB::Server.new *configuration.values_at(:host, :port).compact
        end

        def initialize_database
          @database = ::CouchDB::Database.new *[ @server, configuration[:database] ].compact
        end

        def setup_database
          @database.create_if_missing! if configuration[:create_database_if_missing]
        end

      end

    end

  end

end
