
# Fetches the databases document count.
class GOM::Storage::CouchDB::Counter

  attr_accessor :database

  def initialize(database)
    @database = database
  end

  def perform
    fetch_information
    fetch_count
    @count
  end

  private

  def fetch_information
    @information = @database.information
  end

  def fetch_count
    @count = @information["doc_count"]
  end

end
