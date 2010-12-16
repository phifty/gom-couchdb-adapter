
module GOM

  module Storage

    module CouchDB

      # The couchdb storage adapter.
      class Adapter < GOM::Storage::Adapter

        # If a view could not be found, this error is raised.
        class ViewNotFoundError < StandardError; end

        def setup
          initialize_server
          initialize_database
          setup_database
          push_design
        end

        def fetch(id)
          Fetcher.new(@database, id, revisions).draft
        end

        def store(draft)
          saver = Saver.new @database, draft, revisions, configuration.name
          saver.perform
          saver.id
        end

        def remove(id)
          remover = Remover.new @database, id, revisions
          remover.perform
        end

        def collection(name, options = { })
          view = @design.views[name.to_s]
          raise ViewNotFoundError, "there are no view with the name #{name}" unless view
          fetcher = Collection::Fetcher.new view, options
          GOM::Object::Collection.new fetcher
        end

        def revisions
          @revisions ||= { }
        end

        private

        def initialize_server
          @server = ::CouchDB::Server.new *configuration.values_at(:host, :port).compact
        end

        def initialize_database
          @database = ::CouchDB::Database.new *[ @server, configuration[:database] ].compact
        end

        def setup_database
          delete_database_if_exists, create_database_if_missing = configuration.values_at :delete_database_if_exists, :create_database_if_missing
          @database.delete_if_exists! if delete_database_if_exists
          @database.create_if_missing! if create_database_if_missing
        end

        def push_design
          pusher = View::Pusher.new @database, configuration.views
          pusher.perform
          @design = pusher.design
        end

      end

    end

  end

end
