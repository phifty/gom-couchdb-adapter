
# The couchdb storage adapter.
class GOM::Storage::CouchDB::Adapter < GOM::Storage::Adapter

  attr_reader :server
  attr_reader :database

  def setup
    initialize_server
    initialize_database
    setup_database
    push_design
  end

  def teardown
    clear_server
    clear_database
  end

  def fetch(id)
    GOM::Storage::CouchDB::Fetcher.new(@database, id, revisions).draft
  end

  def store(draft)
    saver = GOM::Storage::CouchDB::Saver.new @database, draft, revisions, configuration.name
    saver.perform
    saver.object_id
  end

  def remove(id)
    remover = GOM::Storage::CouchDB::Remover.new @database, id, revisions
    remover.perform
  end

  def collection(name, options = { })
    view = @design.views[name.to_s]
    raise ViewNotFoundError, "there are no view with the name #{name}" unless view
    fetcher = GOM::Storage::CouchDB::Collection::Fetcher.new view, options
    GOM::Object::Collection.new fetcher, configuration.name
  end

  def revisions
    @revisions ||= { }
  end

  private

  def initialize_server
    @server = ::CouchDB::Server.new *configuration.values_at(:host, :port).compact
  end

  def clear_server
    @server = nil
  end

  def initialize_database
    @database = ::CouchDB::Database.new *[ @server, configuration[:database] ].compact
  end

  def clear_database
    @database = nil
  end

  def setup_database
    delete_database_if_exists, create_database_if_missing = configuration.values_at :delete_database_if_exists, :create_database_if_missing
    @database.delete_if_exists! if delete_database_if_exists
    @database.create_if_missing! if create_database_if_missing
  end

  def push_design
    pusher = GOM::Storage::CouchDB::View::Pusher.new @database, configuration.views
    pusher.perform
    @design = pusher.design
  end

end
