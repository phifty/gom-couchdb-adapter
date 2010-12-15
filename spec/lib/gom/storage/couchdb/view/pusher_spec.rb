require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::View::Pusher do

  before :each do
    @database = mock CouchDB::Database

    @class_view = GOM::Storage::Configuration::View::Class.new "Object"
    @map_reduce_view = GOM::Storage::Configuration::View::MapReduce.new "javascript", "function(document) { }", "function(key, values) { }"
    @view_hash = { "test_class_view" => @class_view, "test_map_reduce_view" => @map_reduce_view }

    @pusher = described_class.new @database, @view_hash
  end

  describe "perform" do

    before :each do
      @design = mock CouchDB::Design, :views => mock(CouchDB::Design::ViewsProxy, :<< => nil), :save => true
      CouchDB::Design.stub(:new).and_return(@design)

      @view = mock CouchDB::Design::View
      CouchDB::Design::View.stub(:new).and_return(@view)

      @class_map_reduce_view = mock GOM::Storage::Configuration::View::MapReduce,
        :language => "javascript", :map => "function(document) { }", :reduce => nil
      @builder = mock GOM::Storage::CouchDB::View::Builder, :map_reduce_view => @class_map_reduce_view
      GOM::Storage::CouchDB::View::Builder.stub(:new).and_return(@builder)
    end

    it "should initialize the design document" do
      CouchDB::Design.should_receive(:new).with(@database, "gom").and_return(@design)
      @pusher.perform
    end

    it "should initialize the builder with the class view" do
      GOM::Storage::CouchDB::View::Builder.should_receive(:new).with(@class_view).and_return(@builder)
      @pusher.perform
    end

    it "should use the builder to create a map reduce view out of the class view" do
      @builder.should_receive(:map_reduce_view).and_return(@class_map_reduce_view)
      @pusher.perform
    end

    it "should initialize the created map reduce view" do
      CouchDB::Design::View.should_receive(:new).with(@design, "test_class_view", "function(document) { }", nil).once.and_return(@view)
      CouchDB::Design::View.should_receive(:new).once.and_return(@view)
      @pusher.perform
    end

    it "should initialize the map reduce view" do
      CouchDB::Design::View.should_receive(:new).once.and_return(@view)
      CouchDB::Design::View.should_receive(:new).with(@design, "test_map_reduce_view", "function(document) { }", "function(key, values) { }").and_return(@view)
      @pusher.perform
    end

    it "should push the design document" do
      @design.should_receive(:save).and_return(true)
      @pusher.perform
    end

  end

end
