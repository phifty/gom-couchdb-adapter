
# Saves the given draft to a CouchDB document.
class GOM::Storage::CouchDB::Saver

  attr_reader :id

  def initialize(database, draft, revisions, relation_storage_name)
    @database, @draft, @revisions, @relation_storage_name = database, draft, revisions, relation_storage_name
  end

  def perform
    initialize_document
    set_properties
    set_relations
    save_document
    store_revision
  end

  private

  def initialize_document
    @document = ::CouchDB::Document.new @database
    @document.id = @draft.id if @draft.id
    @document["model_class"] = @draft.class_name
  end

  def set_properties
    @draft.properties.each do |key, value|
      @document[key.to_s] = value
    end
  end

  def set_relations
    @draft.relations.each do |key, object_proxy|
      id, object = object_proxy.id, object_proxy.object
      @document["#{key}_id"] = if id
                                 id.to_s
                               else
                                 GOM::Storage.store object, @relation_storage_name
                                 GOM::Object.id object
                               end
    end
  end

  def save_document
    @document.save
    @id = @document.id
  end

  def store_revision
    @revisions[@document.id] = @document.rev
  end

end
