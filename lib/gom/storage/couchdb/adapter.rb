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
            database = ::CouchDB::Database.new *[ server, configuration[:database] ].compact
            database.create_if_missing! if configuration[:create_database_if_missing]
            database
          end
        end

        def server
          @server ||= ::CouchDB::Server.new *[ configuration[:host], configuration[:port] ].compact
        end

        def revisions
          @revisions ||= { }
        end

      end

    end

  end

end
