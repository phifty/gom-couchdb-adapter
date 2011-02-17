require 'gom'
require 'couchdb'
require File.join(File.dirname(__FILE__), "storage")

GOM::Storage::Adapter.register :couchdb, GOM::Storage::CouchDB::Adapter
