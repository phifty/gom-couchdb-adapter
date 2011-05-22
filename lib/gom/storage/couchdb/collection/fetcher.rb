
# Fetches a result-set of a CouchDB view and provides it to a GOM collection.
class GOM::Storage::CouchDB::Collection::Fetcher

  def initialize(view, revisions, options)
    @view, @revisions, @options = view, revisions, options
  end

  def drafts
    return nil if @view.reduce
    fetch_collection
    fetch_drafts
    @drafts
  end

  def rows
    fetch_collection
    @collection
  end

  private

  def fetch_collection
    @collection = @view.collection @options
  end

  def fetch_drafts
    @drafts = @collection.documents.map do |document|
      set_revision document
      GOM::Storage::CouchDB::Draft::Builder.new(document).draft
    end
  end

  def set_revision(document)
    @revisions[document.id] = document.rev
  end

end
