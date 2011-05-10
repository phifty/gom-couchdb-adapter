require 'rubygems'
gem 'rspec', '>= 2'
require 'rspec'

require 'gom/spec'

require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "gom", "couchdb-adapter"))

GOM::Storage.configure {
  storage {
    name :test_storage
    adapter :couchdb
    database "test"
    delete_database_if_exists true
    create_database_if_missing true
    view {
      name :test_object_class_view
      type :class
      model_class GOM::Spec::Object
    }
    view {
      name :test_map_view
      type :map_reduce
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
      type :map_reduce
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
