
# Fetches a CouchDB document with the given id and returns a draft.
class GOM::Storage::CouchDB::Fetcher

  attr_accessor :database
  attr_accessor :id
  attr_accessor :revisions

  def initialize(database, id, revisions)
    @database, @id, @revisions = database, id, revisions
  end

  def draft
    initialize_document
    load_document
    build_draft
    @draft
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

  def build_draft
    @draft = GOM::Storage::CouchDB::Draft::Builder.new(@document).draft
  end

end
