require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Collection::Fetcher do

  before :each do
    @document = mock CouchDB::Document
    @documents = [ @document ]
    @collection = mock CouchDB::Collection, :documents => @documents
    @view = mock CouchDB::Design::View, :reduce => nil, :collection => @collection
    @options = mock Hash

    @draft = mock GOM::Object::Draft

    @builder = mock GOM::Storage::CouchDB::Draft::Builder, :draft => @draft
    GOM::Storage::CouchDB::Draft::Builder.stub(:new).and_return(@builder)

    @fetcher = described_class.new @view, @options
  end

  describe "drafts" do

    context "with a view that don't has a reduce function" do

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

    context "with a view that has a reduce function" do

      before :each do
        @view.stub(:reduce).and_return(:test_reduce_function)
      end

      it "should return nil" do
        drafts = @fetcher.drafts
        drafts.should be_nil
      end

    end

  end

  describe "rows" do

    it "should return the original couchdb collection" do
      rows = @fetcher.rows
      rows.should == @collection
    end

  end

end
