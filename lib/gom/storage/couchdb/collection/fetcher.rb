
module GOM

  module Storage

    module CouchDB

      module Collection

        # Fetches a result-set of a CouchDB view and provides it to a GOM collection.
        class Fetcher < GOM::Storage::Collection::Fetcher

          def initialize(view, options)
            @view, @options = view, options
          end

          def drafts
            fetch_collection
            fetch_drafts
            @drafts
          end

          private

          def fetch_collection
            @collection = @view.collection @options
          end

          def fetch_drafts
            @drafts = @collection.documents.map do |document|
              GOM::Storage::CouchDB::Draft::Builder.new(document).draft
            end
          end

        end

      end

    end

  end

end
