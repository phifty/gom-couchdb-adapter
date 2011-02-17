require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "gom", "couchdb-adapter"))

GOM::Storage::Configuration.read File.join(File.dirname(__FILE__), "..", "storage.configuration")

describe "couchdb adapter map reduce collection" do

  before :all do
    GOM::Storage.setup
  end

  before :each do
    @object_one = Object.new
    @object_one.instance_variable_set :@number, 11
    GOM::Storage.store @object_one, :test_storage

    @object_two = Object.new
    @object_two.instance_variable_set :@number, 18
    GOM::Storage.store @object_two, :test_storage

    @collection = GOM::Storage.collection :test_storage, :test_map_reduce_view
  end

  after :each do
    GOM::Storage.remove @object_one
    GOM::Storage.remove @object_two
  end

  describe "first" do

    it "should return a row" do
      row = @collection.first
      row.should be_instance_of(CouchDB::Row)
    end

    it "should return a row with the correct result" do
      row = @collection.first
      row.value.should == 29
    end

  end

end
