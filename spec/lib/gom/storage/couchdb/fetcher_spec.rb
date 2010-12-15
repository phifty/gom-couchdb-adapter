require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Fetcher do

  before :each do
    @database = mock CouchDB::Database
    @id = "test_object_1"
    @revisions = mock Hash, :[]= => nil

    @document = mock CouchDB::Document, :id= => nil, :id => @id, :rev => 1, :load => true
    CouchDB::Document.stub(:new).and_return(@document)

    @draft = mock GOM::Object::Draft
    @builder = mock GOM::Storage::CouchDB::Draft::Builder, :draft => @draft
    GOM::Storage::CouchDB::Draft::Builder.stub(:new).and_return(@builder)

    @fetcher = described_class.new @database, @id, @revisions
  end

  describe "draft" do

    it "should initialize a document" do
      CouchDB::Document.should_receive(:new).with(@database).and_return(@document)
      @fetcher.draft
    end

    it "should load the document" do
      @document.should_receive(:load).and_return(true)
      @fetcher.draft
    end

    it "should store the fetched revision" do
      @revisions.should_receive(:[]=).with(@id, 1)
      @fetcher.draft
    end

    it "should initialize the draft builder" do
      GOM::Storage::CouchDB::Draft::Builder.should_receive(:new).with(@document).and_return(@builder)
      @fetcher.draft
    end

    it "should return the correct draft" do
      draft = @fetcher.draft
      draft.should == @draft
    end

    it "should return nil if document couldn't be loaded" do
      @document.stub(:load).and_raise(CouchDB::Document::NotFoundError)
      draft = @fetcher.draft
      draft.should be_nil
    end

  end

end
