require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "gom", "couchdb-adapter"))

describe "couchdb adapter map collection" do

  before :all do
    GOM::Storage.setup
  end

  before :each do
    @object_one = GOM::Spec::Object.new
    @object_one.number = 11
    GOM::Storage.store @object_one, :test_storage

    @object_two = GOM::Spec::Object.new
    @object_two.number = 18
    GOM::Storage.store @object_two, :test_storage
  end

  after :each do
    GOM::Storage.remove @object_one
    GOM::Storage.remove @object_two
  end

  describe "first" do

    before :each do
      @collection = GOM::Storage.collection :test_storage, :test_map_view
    end

    it "should return an object" do
      object = @collection.first
      object.should be_instance_of(GOM::Spec::Object)
    end

    it "should return a row with the correct result" do
      object = @collection.first
      object.number.should == 11
    end

  end

  describe "updating a collection object" do

    before :each do
      # clear all revisions and re-fetch object two to restore that revision
      GOM::Storage::Configuration[:test_storage].adapter.clear_revisions!
      GOM::Storage.fetch GOM::Object.id(@object_two)

      @collection = GOM::Storage.collection :test_storage, :test_map_view

      @object = @collection.first
      @object.number = 21
      GOM::Storage.store @object
    end

    it "should have the new values if fetched again" do
      object = GOM::Storage.fetch GOM::Object.id(@object)
      object.number.should == 21
    end

  end

end
