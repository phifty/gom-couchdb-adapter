
module GOM

  module Storage

    module CouchDB

      module View

        autoload :Builder, File.join(File.dirname(__FILE__), "view", "builder")
        autoload :Pusher, File.join(File.dirname(__FILE__), "view", "pusher")

      end

    end

  end

end
