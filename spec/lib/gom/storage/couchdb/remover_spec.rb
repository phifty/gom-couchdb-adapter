require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Remover do

  before :each do
    @database = mock CouchDB::Database
    @id = "test_object_1"
    @revisions = mock Hash, :[] => 1

    @remover = described_class.new @database, @id, @revisions
  end

  describe "perform" do

    before :each do
      @document = mock CouchDB::Document, :id= => nil, :rev= => nil, :destroy => true
      CouchDB::Document.stub(:new).and_return(@document)
    end

    it "should initialize a document" do
      CouchDB::Document.should_receive(:new).with(@database).and_return(@document)
      @remover.perform
    end

    it "should set the id" do
      @document.should_receive(:id=).with("test_object_1")
      @remover.perform
    end

    it "should set the revision" do
      @revisions.should_receive(:[]).with("test_object_1").and_return(1)
      @document.should_receive(:rev=).with(1)
      @remover.perform
    end

    it "should destroy the document" do
      @document.should_receive(:destroy).and_return(true)
      @remover.perform
    end

  end

end
