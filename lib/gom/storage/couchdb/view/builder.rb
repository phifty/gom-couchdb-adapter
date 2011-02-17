
# Builds a javascript map-reduce-view out of a class view.
class GOM::Storage::CouchDB::View::Builder

  def initialize(class_view)
    @class_view = class_view
  end

  def map_reduce_view
    GOM::Storage::Configuration::View::MapReduce.new(
      "function(document) {\n  if (document['model_class'] == '#{@class_view.class_name}') {\n    emit(document['_id'], null);\n  }\n}",
      nil
    )
  end

end
