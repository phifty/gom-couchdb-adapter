
module GOM

  module Storage

    module CouchDB

      # Fetches a CouchDB document with the given id and returns an object hash.
      class Fetcher

        attr_reader :object_hash

        def initialize(database, id, revisions)
          @database, @id, @revisions = database, id, revisions
        end

        def perform
          initialize_document
          load_document
          return unless has_object_hash?
          transfer_properties
          transfer_class
        end

        private

        def initialize_document
          @document = ::CouchDB::Document.new @database
          @document.id = @id
        end

        def load_document
          @document.load
          @object_hash = { :id => @document.id }
          set_revision
        rescue ::CouchDB::Document::NotFoundError
          @object_hash = nil
        end

        def set_revision
          @revisions[@document.id] = @document.rev
        end

        def has_object_hash?
          !!@object_hash
        end

        def transfer_properties
          @document.each do |key, value|
            set_property key, value if property_key?(key)
            set_relation key, value if relation_key?(key)
          end
        end

        def transfer_class
          @object_hash[:class] = @document["model_class"]
        end

        def property_key?(key)
          !relation_key?(key) && ![ "_id", "_rev", "model_class" ].include?(key)
        end

        def relation_key?(key)
          key =~ /.+_id$/
        end

        def set_property(key, value)
          @object_hash[:properties] ||= { }
          @object_hash[:properties][key.to_sym] = value
        end

        def set_relation(key, value)
          name = key.sub /_id$/, ""
          id = GOM::Object::Id.new value
          @object_hash[:relations] ||= { }
          @object_hash[:relations][name.to_sym] = GOM::Object::Proxy.new id
        end

      end

    end

  end

end
