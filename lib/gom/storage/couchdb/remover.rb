
module GOM

  module Storage

    module CouchDB

      # Removes the CouchDB document with the given id.
      class Remover

        def initialize(database, id, revisions)
          @database, @id, @revisions = database, id, revisions
        end

        def perform
          initialize_document
          destroy_document
        end

        private

        def initialize_document
          @document = ::CouchDB::Document.new @database
          @document.id = @id
          @document.rev = @revisions[@id]
        end

        def destroy_document
          @document.destroy
        end

      end

    end

  end

end
