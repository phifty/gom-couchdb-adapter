require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Fetcher do

  before :each do
    @database = mock CouchDB::Database
    @id = "test_object_1"
    @revisions = mock Hash, :[]= => nil

    @fetcher = described_class.new @database, @id, @revisions
  end

  describe "perform" do

    before :each do
      @document = mock CouchDB::Document, :id => "test_object_1", :id= => nil, :rev => 1, :[] => "Object", :load => true
      @document.stub(:each).and_yield("test", "test value")
      CouchDB::Document.stub(:new).and_return(@document)
    end

    it "should initialize a document" do
      CouchDB::Document.should_receive(:new).with(@database).and_return(@document)
      @fetcher.perform
    end

    it "should set the id" do
      @document.should_receive(:id=).with("test_object_1")
      @fetcher.perform
    end

    it "should load the document" do
      @document.should_receive(:load).and_return(true)
      @fetcher.perform
    end

    it "should store the fetched revision" do
      @revisions.should_receive(:[]=).with(@id, 1)
      @fetcher.perform
    end

    it "should transfer the class" do
      @document.stub(:[]).with("model_class").and_return("Object")
      @fetcher.perform
      @fetcher.object_hash.should include(:class => "Object")
    end

    it "should transfer each property" do
      @fetcher.perform
      @fetcher.object_hash.should include(:properties => { :test => "test value" })
    end

    it "should transfer each relation" do
      @document.stub(:each).and_yield("test_id", "test_storage:test_object_2")
      @fetcher.perform
      @fetcher.object_hash[:relations][:test].should be_instance_of(GOM::Object::Proxy)
    end

    it "should return the correct object hash" do
      @fetcher.perform
      object_hash = @fetcher.object_hash
      object_hash.should == {
        :id => "test_object_1",
        :class => "Object",
        :properties => { :test => "test value" }
      }
    end

    it "should set object hash to nil if document couldn't be loaded" do
      @document.stub(:load).and_raise(CouchDB::Document::NotFoundError)
      @fetcher.perform
      @fetcher.object_hash.should be_nil
    end

  end

end
