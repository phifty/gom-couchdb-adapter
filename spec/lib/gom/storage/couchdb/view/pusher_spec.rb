require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::View::Pusher do

  before :each do
    @database = mock CouchDB::Database

    @all_view_configuration = GOM::Storage::Configuration::View::All.new
    @property_view_configuration = GOM::Storage::Configuration::View::Property.new :filter, :properties
    @class_view_configuration = GOM::Storage::Configuration::View::Class.new "Object"
    @map_reduce_view_configuration = GOM::Storage::Configuration::View::MapReduce.new "function(document) { }", "function(key, values) { }"
    @view_hash = {
      "test_all_view" => @all_view_configuration,
      "test_property_view" => @property_view_configuration,
      "test_class_view" => @class_view_configuration,
      "test_map_reduce_view" => @map_reduce_view_configuration
    }

    @pusher = described_class.new @database, @view_hash
  end

  describe "perform" do

    before :each do
      @design = mock CouchDB::Design, :views => mock(CouchDB::Design::ViewsProxy, :<< => nil), :fetch_rev => nil, :save => true
      CouchDB::Design.stub :new => @design

      @all_view = mock CouchDB::Design::View
      @property_view = mock CouchDB::Design::View
      @class_view = mock CouchDB::Design::View
      @map_reduce_view = mock CouchDB::Design::View
      CouchDB::Design::View.stub :new do |design, name, map_function, reduce_function|
        {
          "test_all_view" => @all_view,
          "test_property_view" => @property_view,
          "test_class_view" => @class_view,
          "test_map_reduce_view" => @map_reduce_view
        }[name]
      end

      @all_map_reduce_view = mock GOM::Storage::Configuration::View::MapReduce,
        :map => "function(document) { }", :reduce => nil
      @builder_for_all = mock GOM::Storage::CouchDB::View::BuilderForAll, :map_reduce_view => @all_map_reduce_view
      GOM::Storage::CouchDB::View::BuilderForAll.stub :new => @builder_for_all

      @property_map_reduce_view = mock GOM::Storage::Configuration::View::MapReduce,
        :map => "function(document) { }", :reduce => nil
      @builder_from_property = mock GOM::Storage::CouchDB::View::BuilderFromProperty, :map_reduce_view => @property_map_reduce_view
      GOM::Storage::CouchDB::View::BuilderFromProperty.stub :new => @builder_from_property

      @class_map_reduce_view = mock GOM::Storage::Configuration::View::MapReduce,
        :map => "function(document) { }", :reduce => nil
      @builder_from_class = mock GOM::Storage::CouchDB::View::BuilderFromClass, :map_reduce_view => @class_map_reduce_view
      GOM::Storage::CouchDB::View::BuilderFromClass.stub :new => @builder_from_class
    end

    it "should initialize the design document" do
      CouchDB::Design.should_receive(:new).with(@database, "gom").and_return(@design)
      @pusher.perform
    end

    it "should initialize the builder with the all view" do
      GOM::Storage::CouchDB::View::BuilderForAll.should_receive(:new).with(@all_view_configuration).and_return(@builder_for_all)
      @pusher.perform
    end

    it "should use the builder to generate a map reduce view for all objects" do
      @builder_for_all.should_receive(:map_reduce_view).and_return(@all_map_reduce_view)
      @pusher.perform
    end

    it "should initialize the builder with the property view" do
      GOM::Storage::CouchDB::View::BuilderFromProperty.should_receive(:new).with(@property_view_configuration).and_return(@builder_from_property)
      @pusher.perform
    end

    it "should use the builder to generate a map reduce view out of the property view" do
      @builder_from_property.should_receive(:map_reduce_view).and_return(@property_map_reduce_view)
      @pusher.perform
    end

    it "should initialize the builder with the class view" do
      GOM::Storage::CouchDB::View::BuilderFromClass.should_receive(:new).with(@class_view_configuration).and_return(@builder_from_class)
      @pusher.perform
    end

    it "should use the builder to generate a map reduce view out of the class view" do
      @builder_from_class.should_receive(:map_reduce_view).and_return(@class_map_reduce_view)
      @pusher.perform
    end

    it "should add the generated map reduce view" do
      @design.views.should_receive(:<<).with(@class_view)
      @pusher.perform
    end

    it "should add the map reduce view" do
      @design.views.should_receive(:<<).with(@map_reduce_view)
      @pusher.perform
    end

    it "should push the design document" do
      @design.should_receive(:save).and_return(true)
      @pusher.perform
    end

  end

end
