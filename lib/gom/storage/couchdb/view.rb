
module GOM::Storage::CouchDB::View

  autoload :BuilderForAll, File.join(File.dirname(__FILE__), "view", "builder_for_all")
  autoload :BuilderFromClass, File.join(File.dirname(__FILE__), "view", "builder_from_class")
  autoload :BuilderFromProperty, File.join(File.dirname(__FILE__), "view", "builder_from_property")
  autoload :Pusher, File.join(File.dirname(__FILE__), "view", "pusher")

end
