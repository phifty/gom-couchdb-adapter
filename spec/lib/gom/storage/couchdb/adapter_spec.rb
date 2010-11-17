require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Adapter do

  before :each do
    @server = mock CouchDB::Server
    CouchDB::Server.stub(:new).and_return(@server)

    @database = mock CouchDB::Database
    CouchDB::Database.stub(:new).and_return(@database)

    @configuration = mock GOM::Storage::Configuration, :name => "test_storage"
    @configuration.stub(:[])

    @adapter = GOM::Storage::CouchDB::Adapter.new @configuration
  end

  it "should register the adapter" do
    GOM::Storage::Adapter[:couchdb].should == GOM::Storage::CouchDB::Adapter
  end

  describe "fetch" do

    before :each do
      @id = "test_object_1"
      @revisions = @adapter.send :revisions
      @object_hash = mock Hash

      @fetcher = mock GOM::Storage::CouchDB::Fetcher, :perform => nil, :object_hash => @object_hash
      GOM::Storage::CouchDB::Fetcher.stub(:new).and_return(@fetcher)
    end

    it "should initialize the fetcher" do
      GOM::Storage::CouchDB::Fetcher.should_receive(:new).with(@database, @id, @revisions).and_return(@fetcher)
      @adapter.fetch @id
    end

    it "should perform a fetch" do
      @fetcher.should_receive(:perform)
      @adapter.fetch @id
    end

    it "should return the object_hash" do
      @adapter.fetch(@id).should == @object_hash
    end

  end

  describe "store" do

    before :each do
      @document = mock CouchDB::Document, :[]= => nil, :id= => nil, :save => true, :id => "test_object_1"
      CouchDB::Document.stub(:new).and_return(@document)

      @object_hash = { :id => "test_object_1" }
    end

    it "should initialize a document" do
      CouchDB::Document.should_receive(:new).with(@database).and_return(@document)
      @adapter.store @object_hash
    end

    context "object hash with properties" do

      before :each do
        @object_hash.merge! :properties => { :test => "test value" }
      end

      it "should set the properties" do
        @document.should_receive(:[]=).with("test", "test value")
        @adapter.store @object_hash
      end

    end

    context "object hash with relations" do

      before :each do
        @related_object = Object.new
        @related_object_id = mock GOM::Object::Id, :to_s => "test_storage:test_object_2"
        @related_object_proxy = mock GOM::Object::Proxy, :id => @related_object_id

        GOM::Storage.stub(:store)
        GOM::Object.stub(:id).and_return(@related_object_id)

        @object_hash.merge! :relations => { :related_object => @related_object_proxy }
      end

      it "should set the relations" do
        @document.should_receive(:[]=).with("related_object_id", "test_storage:test_object_2")
        @adapter.store @object_hash
      end

      it "should store the related object if it hasn't an id" do
        GOM::Storage.should_receive(:store).with(@related_object, "test_storage")
        GOM::Object.should_receive(:id).with(@related_object).and_return(@related_object_id)

        @related_object_proxy.stub(:id).and_return(nil)
        @related_object_proxy.stub(:object).and_return(@related_object)

        @adapter.store @object_hash
      end

    end

    it "should set the id" do
      @document.should_receive(:id=).with("test_object_1")
      @adapter.store @object_hash
    end

    it "should not set the id if not included in the object hash" do
      @document.should_not_receive(:id=)
      @object_hash.delete :id
      @adapter.store @object_hash
    end

    it "should save the document" do
      @document.should_receive(:save).and_return(true)
      @adapter.store @object_hash
    end

    it "should return the (new) object id" do
      result = @adapter.store @object_hash
      result.should == "test_object_1"
    end

  end

  describe "remove" do

    before :each do
      @document = mock CouchDB::Document, :id= => nil, :destroy => true
      CouchDB::Document.stub(:new).and_return(@document)
    end

    it "should initialize a document" do
      CouchDB::Document.should_receive(:new).with(@database).and_return(@document)
      @adapter.remove "test_object_1"
    end

    it "should set the id" do
      @document.should_receive(:id=).with("test_object_1")
      @adapter.remove "test_object_1"
    end

    it "should destroy the document" do
      @document.should_receive(:destroy)
      @adapter.remove "test_object_1"
    end

  end

end
