
module GOM

  module Storage

    module CouchDB

      # Saves the given object hash to a CouchDB document.
      class Saver

        attr_reader :id

        def initialize(database, object_hash, revisions, relation_storage_name)
          @database, @object_hash, @revisions, @relation_storage_name = database, object_hash, revisions, relation_storage_name
        end

        def perform
          initialize_document
          set_properties
          set_relations
          save_document
          store_revision
        end

        private

        def initialize_document
          @document = ::CouchDB::Document.new @database
          @document.id = @object_hash[:id] if @object_hash.has_key?(:id)
          @document["model_class"] = @object_hash[:class]
        end

        def set_properties
          (@object_hash[:properties] || { }).each do |key, value|
            @document[key.to_s] = value
          end
        end

        def set_relations
          (@object_hash[:relations] || { }).each do |key, object_proxy|
            @document["#{key}_id"] = if object_proxy.id
                                       object_proxy.id.to_s
                                     else
                                       GOM::Storage.store object_proxy.object, @relation_storage_name
                                       GOM::Object.id object_proxy.object
                                     end
          end
        end

        def save_document
          @document.save
          @id = @document.id
        end

        def store_revision
          @revisions[@document.id] = @document.rev
        end

      end

    end

  end

end
