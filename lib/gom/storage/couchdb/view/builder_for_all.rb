
# Builds a javascript map-reduce-view for all objects.
class GOM::Storage::CouchDB::View::BuilderForAll

  def initialize(all_view)
    @all_view = all_view
  end

  def map_reduce_view
    GOM::Storage::Configuration::View::MapReduce.new(
      "function(document) {\n  if (document['model_class']) {\n    emit(document['_id'], null);\n  }\n}",
      nil
    )
  end

end
