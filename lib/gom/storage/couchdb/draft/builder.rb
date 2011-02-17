
# Builds a draft out of a CouchDB document.
class GOM::Storage::CouchDB::Draft::Builder

  def initialize(document)
    @document = document
  end

  def draft
    initialize_draft
    set_id
    set_class
    set_properties_and_relations
    @draft
  end

  private

  def initialize_draft
    @draft = GOM::Object::Draft.new
  end

  def set_id
    @draft.id = @document.id
  end

  def set_class
    @draft.class_name = @document["model_class"]
  end

  def set_properties_and_relations
    @document.each do |key, value|
      set_property key, value if property_key?(key)
      set_relation key, value if relation_key?(key)
    end
  end

  def set_property(key, value)
    @draft.properties[key.to_sym] = value
  end

  def set_relation(key, value)
    name = key.sub /_id$/, ""
    id = GOM::Object::Id.new value
    @draft.relations[name.to_sym] = GOM::Object::Proxy.new id
  end

  def property_key?(key)
    !relation_key?(key) && ![ "_id", "_rev", "model_class" ].include?(key)
  end

  def relation_key?(key)
    key =~ /.+_id$/
  end

end
