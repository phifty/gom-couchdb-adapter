
GOM::Storage.configure {
  storage {
    name :test_storage
    adapter :couchdb
    database "test"
    delete_database_if_exists true
    create_database_if_missing true
    view {
      name :test_property_view
      kind :property
      filter {
        model_class :equals, "GOM::Spec::Object"
        number :greater_than, 13
      }
      properties :_id
    }
    view {
      name :test_object_class_view
      kind :class
      model_class GOM::Spec::Object
    }
    view {
      name :test_map_view
      kind :map_reduce
      map_function """
        function(document) {
          if (document['number'] == 11) {
            emit(document['_id'], null);
          }
        }
      """
    }
    view {
      name :test_map_reduce_view
      kind :map_reduce
      map_function """
        function(document) {
          if (document['number']) {
            emit(document['_id'], document['number']);
          }
        }
      """
      reduce_function """
        function(keys, values, rereduce) {
          return sum(values);
        }
      """
    }
  }
}
