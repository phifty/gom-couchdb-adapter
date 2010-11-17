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
          document = ::CouchDB::Document.new database
          (object_hash[:properties] || { }).each do |key, value|
            document[key.to_s] = value
          end
          (object_hash[:relations] || { }).each do |key, object_proxy|
            document["#{key}_id"] = if object_proxy.id
                                      object_proxy.id.to_s
                                    else
                                      GOM::Storage.store object_proxy.object, configuration.name
                                      GOM::Object.id object_proxy.object
                                    end
          end
          document.id = object_hash[:id] if object_hash.has_key?(:id)
          document["model_class"] = object_hash[:class]
          document.save

          @revisions ||= { }
          @revisions[document.id] = document.rev

          document.id
        end

        def remove(id)
          @revisions ||= { }
          document = ::CouchDB::Document.new database
          document.id = id
          document.rev = @revisions[id]
          document.destroy
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
