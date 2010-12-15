
module GOM

  module Storage

    module CouchDB

      module ObjectHash

        # Builds an object hash out of a CouchDB document.
        class Builder

          def initialize(document)
            @document = document
          end

          def object_hash
            @object_hash = { }
            set_id
            set_class
            set_properties_and_relations
            @object_hash
          end

          private

          def set_id
            @object_hash[:id] = @document.id
          end

          def set_class
            @object_hash[:class] = @document["model_class"]
          end

          def set_properties_and_relations
            @document.each do |key, value|
              set_property key, value if property_key?(key)
              set_relation key, value if relation_key?(key)
            end
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

          def property_key?(key)
            !relation_key?(key) && ![ "_id", "_rev", "model_class" ].include?(key)
          end

          def relation_key?(key)
            key =~ /.+_id$/
          end

        end

      end

    end

  end

end
