require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Adapter do

  before :each do
    @server = mock CouchDB::Server
    CouchDB::Server.stub(:new).and_return(@server)

    @database = mock CouchDB::Database, :create_if_missing! => nil
    CouchDB::Database.stub(:new).and_return(@database)

    @configuration = mock GOM::Storage::Configuration, :name => "test_storage", :[] => nil
    @configuration.stub(:values_at) do |*arguments|
      result = nil
      result = [ "test", true ] if arguments == [ :database, :create_database_if_missing ]
      result = [ "host", 1234 ] if arguments == [ :host, :port ]
      result
    end

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
      @object_hash = mock Hash
      @revisions = @adapter.send :revisions
      @id = "test_object_1"

      @saver = mock GOM::Storage::CouchDB::Saver, :perform => nil, :id => @id
      GOM::Storage::CouchDB::Saver.stub(:new).and_return(@saver)
    end

    it "should initialize the saver" do
      GOM::Storage::CouchDB::Saver.should_receive(:new).with(@database, @object_hash, @revisions, "test_storage").and_return(@saver)
      @adapter.store @object_hash
    end

    it "should perform a fetch" do
      @saver.should_receive(:perform)
      @adapter.store @object_hash
    end

    it "should return the object_hash" do
      @adapter.store(@object_hash).should == @id
    end

  end

  describe "remove" do

    before :each do
      @id = "test_object_1"
      @revisions = @adapter.send :revisions

      @remover = mock GOM::Storage::CouchDB::Remover, :perform => nil
      GOM::Storage::CouchDB::Remover.stub(:new).and_return(@remover)
    end

    it "should initialize the remover" do
      GOM::Storage::CouchDB::Remover.should_receive(:new).with(@database, @id, @revisions).and_return(@remover)
      @adapter.remove @id
    end

    it "should perform a fetch" do
      @remover.should_receive(:perform)
      @adapter.remove @id
    end

  end

end
