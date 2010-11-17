require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "couchdb", "server"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "couchdb", "database"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "couchdb", "document"))

module GOM

  module Storage

    module CouchDB

      # The couchdb storage adapter
      class Adapter < GOM::Storage::Adapter

        def fetch(id)
          document = ::CouchDB::Document.new database
          document.id = id
          document.load

          @revisions ||= { }
          @revisions[id] = document.rev

          object_hash = { :id => id, :class => document["model_class"] }
          document.each_property do |key, value|
            if key != "_id" && key != "_rev" && key != "model_class"
              if key =~ /_id$/
                name = key.sub /_id$/, ""
                id = GOM::Object::Id.new value
                object_hash[:relations] ||= { }
                object_hash[:relations][name.to_sym] = GOM::Object::Proxy.new id
              else
                object_hash[:properties] ||= { }
                object_hash[:properties][key.to_sym] = value
              end
            end
          end
          (object_hash[:properties] || object_hash[:relations]) ? object_hash : nil
        rescue ::CouchDB::Document::NotFoundError
          nil
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

      end

    end

  end

end
