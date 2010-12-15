require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Collection::Fetcher do

  before :each do
    @document = mock CouchDB::Document
    @documents = [ @document ]
    @collection = mock CouchDB::Collection, :documents => @documents
    @view = mock CouchDB::Design::View, :collection => @collection
    @options = mock Hash

    @object_hash = mock Hash

    @builder = mock GOM::Storage::CouchDB::ObjectHash::Builder, :object_hash => @object_hash
    GOM::Storage::CouchDB::ObjectHash::Builder.stub(:new).and_return(@builder)

    @fetcher = described_class.new @view, @options
  end

  describe "object_hashes" do

    it "should pass the options to the collection of the view" do
      @view.should_receive(:collection).with(@options).and_return(@collection)
      @fetcher.object_hashes
    end

    it "should initialize the object hash builder of each document" do
      GOM::Storage::CouchDB::ObjectHash::Builder.should_receive(:new).with(@document).and_return(@builder)
      @fetcher.object_hashes
    end

    it "should return an array of object hashes" do
      object_hashes = @fetcher.object_hashes
      object_hashes.should == [ @object_hash ]
    end

  end

end
