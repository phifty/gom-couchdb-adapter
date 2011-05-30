require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::View::Pusher do

  before :each do
    @database = mock CouchDB::Database

    @class_view_configuration = GOM::Storage::Configuration::View::Class.new "Object"
    @map_reduce_view_configuration = GOM::Storage::Configuration::View::MapReduce.new "function(document) { }", "function(key, values) { }"
    @view_hash = { "test_class_view" => @class_view_configuration, "test_map_reduce_view" => @map_reduce_view_configuration }

    @pusher = described_class.new @database, @view_hash
  end

  describe "perform" do

    before :each do
      @design = mock CouchDB::Design, :views => mock(CouchDB::Design::ViewsProxy, :<< => nil), :save => true
      CouchDB::Design.stub :new => @design

      @class_view = mock CouchDB::Design::View
      @map_reduce_view = mock CouchDB::Design::View
      CouchDB::Design::View.stub :new do |design, name, map_function, reduce_function|
        { "test_class_view" => @class_view, "test_map_reduce_view" => @map_reduce_view }[name]
      end

      @class_map_reduce_view = mock GOM::Storage::Configuration::View::MapReduce,
        :map => "function(document) { }", :reduce => nil
      @builder = mock GOM::Storage::CouchDB::View::Builder, :map_reduce_view => @class_map_reduce_view
      GOM::Storage::CouchDB::View::Builder.stub :new => @builder
    end

    it "should initialize the design document" do
      CouchDB::Design.should_receive(:new).with(@database, "gom").and_return(@design)
      @pusher.perform
    end

    it "should initialize the builder with the class view" do
      GOM::Storage::CouchDB::View::Builder.should_receive(:new).with(@class_view_configuration).and_return(@builder)
      @pusher.perform
    end

    it "should use the builder to generate a map reduce view out of the class view" do
      @builder.should_receive(:map_reduce_view).and_return(@class_map_reduce_view)
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
