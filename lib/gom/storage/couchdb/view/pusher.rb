
module GOM

  module Storage

    module CouchDB

      module View

        # A helper to push design documents to the CouchDB server.
        class Pusher

          attr_reader :design

          def initialize(database, view_hash)
            @database, @view_hash = database, view_hash
          end

          def perform
            initialize_design
            add_views
            push_design
          end

          private

          def initialize_design
            @design = ::CouchDB::Design.new @database, "gom"
          end

          def add_views
            @view_hash.each do |name, view|
              add_view name.to_s, view
            end
          end

          def push_design
            @design.save
          end

          def add_view(name, view)
            case view.class.to_s
              when "GOM::Storage::Configuration::View::Class"
                add_view_by_class_view name, view
              when "GOM::Storage::Configuration::View::MapReduce"
                add_view_by_map_reduce_view name, view
            end
          end

          def add_view_by_class_view(name, class_view)
            map_reduce_view = Builder.new(class_view).map_reduce_view
            @design.views << ::CouchDB::Design::View.new(@design, name, map_reduce_view.map, map_reduce_view.reduce)
          end

          def add_view_by_map_reduce_view(name, map_reduce_view)
            @design.views << ::CouchDB::Design::View.new(@design, name, map_reduce_view.map, map_reduce_view.reduce)
          end

        end

      end

    end

  end

end
