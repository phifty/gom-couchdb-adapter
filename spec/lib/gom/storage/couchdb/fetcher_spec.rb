require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Fetcher do

  before :each do
    @database = mock CouchDB::Database
    @id = "test_object_1"
    @revisions = mock Hash, :[]= => nil

    @document = mock CouchDB::Document, :id= => nil, :id => @id, :rev => 1, :load => true
    CouchDB::Document.stub(:new).and_return(@document)

    @object_hash = mock Hash
    @builder = mock GOM::Storage::CouchDB::ObjectHash::Builder, :object_hash => @object_hash
    GOM::Storage::CouchDB::ObjectHash::Builder.stub(:new).and_return(@builder)

    @fetcher = described_class.new @database, @id, @revisions
  end

  describe "object_hash" do

    it "should initialize a document" do
      CouchDB::Document.should_receive(:new).with(@database).and_return(@document)
      @fetcher.object_hash
    end

    it "should load the document" do
      @document.should_receive(:load).and_return(true)
      @fetcher.object_hash
    end

    it "should store the fetched revision" do
      @revisions.should_receive(:[]=).with(@id, 1)
      @fetcher.object_hash
    end

    it "should initialize the object hash builder" do
      GOM::Storage::CouchDB::ObjectHash::Builder.should_receive(:new).with(@document).and_return(@builder)
      @fetcher.object_hash
    end

    it "should return the correct object hash" do
      object_hash = @fetcher.object_hash
      object_hash.should == @object_hash
    end

    it "should set object hash to nil if document couldn't be loaded" do
      @document.stub(:load).and_raise(CouchDB::Document::NotFoundError)
      object_hash = @fetcher.object_hash
      object_hash.should be_nil
    end

  end

end
