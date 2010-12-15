require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Collection::Fetcher do

  before :each do
    @document = mock CouchDB::Document
    @documents = [ @document ]
    @collection = mock CouchDB::Collection, :documents => @documents
    @view = mock CouchDB::Design::View, :collection => @collection
    @options = mock Hash

    @draft = mock GOM::Object::Draft

    @builder = mock GOM::Storage::CouchDB::Draft::Builder, :draft => @draft
    GOM::Storage::CouchDB::Draft::Builder.stub(:new).and_return(@builder)

    @fetcher = described_class.new @view, @options
  end

  describe "drafts" do

    it "should pass the options to the collection of the view" do
      @view.should_receive(:collection).with(@options).and_return(@collection)
      @fetcher.drafts
    end

    it "should initialize the draft builder of each document" do
      GOM::Storage::CouchDB::Draft::Builder.should_receive(:new).with(@document).and_return(@builder)
      @fetcher.drafts
    end

    it "should return an array of drafts" do
      drafts = @fetcher.drafts
      drafts.should == [ @draft ]
    end

  end

end
