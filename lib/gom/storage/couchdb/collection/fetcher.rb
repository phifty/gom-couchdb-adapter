
module GOM

  module Storage

    module CouchDB

      module Collection

        # Fetches a result-set of a CouchDB view and transfers it in a GOM collection.
        class Fetcher < GOM::Storage::Collection::Fetcher

          def initialize(view, options)
            @view, @options = view, options
          end

          def object_hashes
            fetch_collection
            fetch_object_hashes
            @object_hashes
          end

          private

          def fetch_collection
            @collection = @view.collection @options
          end

          def fetch_object_hashes
            @object_hashes = @collection.documents.map do |document|
              GOM::Storage::CouchDB::ObjectHash::Builder.new(document).object_hash
            end
          end

        end

      end

    end

  end

end
