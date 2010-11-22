require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "couchdb", "server"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "couchdb", "database"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "couchdb", "document"))

module GOM

  module Storage

    module CouchDB

      # The couchdb storage adapter
      class Adapter < GOM::Storage::Adapter

        def fetch(id)
          fetcher = Fetcher.new database, id, revisions
          fetcher.perform
          fetcher.object_hash
        end

        def store(object_hash)
          saver = Saver.new database, object_hash, revisions, configuration.name
          saver.perform
          saver.id
        end

        def remove(id)
          remover = Remover.new database, id, revisions
          remover.perform
        end

        private

        def database
          @database ||= begin
            database, create_database_if_missing = configuration.values_at :database, :create_database_if_missing
            database = ::CouchDB::Database.new *[ server, database ].compact
            database.create_if_missing! if create_database_if_missing
            database
          end
        end

        def server
          @server ||= ::CouchDB::Server.new *configuration.values_at(:host, :port).compact
        end

        def revisions
          @revisions ||= { }
        end

      end

    end

  end

end
