
module GOM

  module Storage

    module CouchDB

      # Fetches a CouchDB document with the given id and returns an object hash.
      class Fetcher

        attr_reader :object_hash

        def initialize(database, id, revisions)
          @database, @id, @revisions = database, id, revisions
        end

        def object_hash
          initialize_document
          load_document
          build_object_hash
          @object_hash
        rescue ::CouchDB::Document::NotFoundError
          nil
        end

        private

        def initialize_document
          @document = ::CouchDB::Document.new @database
          @document.id = @id
        end

        def load_document
          @document.load
          set_revision
        end

        def set_revision
          @revisions[@document.id] = @document.rev
        end

        def build_object_hash
          @object_hash = GOM::Storage::CouchDB::ObjectHash::Builder.new(@document).object_hash
        end

      end

    end

  end

end
