require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Adapter do

  before :each do
    @server = mock CouchDB::Server
    CouchDB::Server.stub :new => @server

    @database = mock CouchDB::Database, :delete_if_exists! => nil, :create_if_missing! => nil
    CouchDB::Database.stub :new => @database

    @configuration = mock GOM::Storage::Configuration, :name => "test_storage", :views => :test_views
    @configuration.stub :[] do |key|
      case key
        when :database then "test"
      end
    end
    @configuration.stub :values_at do |*arguments|
      case arguments
        when [ :host, :port, :username, :password ] then [ "host", 1234, "test", "test" ]
        when [ :delete_database_if_exists, :create_database_if_missing ] then [ true, true ]
      end
    end

    @design = mock CouchDB::Design
    @pusher = mock GOM::Storage::CouchDB::View::Pusher, :perform => nil, :design => @design
    GOM::Storage::CouchDB::View::Pusher.stub :new => @pusher

    @adapter = described_class.new @configuration
  end

  it "should register the adapter" do
    GOM::Storage::Adapter[:couchdb].should == GOM::Storage::CouchDB::Adapter
  end

  describe "#setup" do

    it "should initialize a server" do
      CouchDB::Server.should_receive(:new).with("host", 1234, "test", "test").and_return(@server)
      @adapter.setup
    end

    it "should initialize a database" do
      CouchDB::Database.should_receive(:new).with(@server, "test").and_return(@database)
      @adapter.setup
    end

    it "should delete the database if requested and existing" do
      @database.should_receive(:delete_if_exists!)
      @adapter.setup
    end

    it "should create the database if requested and missing" do
      @database.should_receive(:create_if_missing!)
      @adapter.setup
    end

    it "should initialize the view pusher" do
      GOM::Storage::CouchDB::View::Pusher.should_receive(:new).with(@database, :test_views).and_return(@pusher)
      @adapter.setup
    end

    it "should push the views" do
      @pusher.should_receive(:perform)
      @adapter.setup
    end

  end

  describe "#teardown" do

    before :each do
      @adapter.setup
    end

    it "should clear the server" do
      lambda do
        @adapter.teardown
      end.should change(@adapter, :server).from(@server).to(nil)
    end

    it "should clear the database" do
      lambda do
        @adapter.teardown
      end.should change(@adapter, :database).from(@database).to(nil)
    end

  end

  describe "#fetch" do

    before :each do
      @adapter.setup

      @id = "test_object_1"
      @revisions = @adapter.send :revisions
      @draft = mock GOM::Object::Draft

      @fetcher = mock GOM::Storage::CouchDB::Fetcher, :draft => @draft
      GOM::Storage::CouchDB::Fetcher.stub :new => @fetcher
    end

    it "should initialize the fetcher" do
      GOM::Storage::CouchDB::Fetcher.should_receive(:new).with(@database, @id, @revisions).and_return(@fetcher)
      @adapter.fetch @id
    end

    it "should return the draft" do
      @adapter.fetch(@id).should == @draft
    end

  end

  describe "#store" do

    before :each do
      @adapter.setup

      @draft = mock GOM::Object::Draft
      @revisions = @adapter.send :revisions
      @object_id = "object_1"

      @saver = mock GOM::Storage::CouchDB::Saver, :perform => nil, :object_id => @object_id
      GOM::Storage::CouchDB::Saver.stub :new => @saver
    end

    it "should initialize the saver" do
      GOM::Storage::CouchDB::Saver.should_receive(:new).with(@database, @draft, @revisions, "test_storage").and_return(@saver)
      @adapter.store @draft
    end

    it "should perform a fetch" do
      @saver.should_receive(:perform)
      @adapter.store @draft
    end

    it "should return the draft" do
      @adapter.store(@draft).should == @object_id
    end

  end

  describe "#remove" do

    before :each do
      @adapter.setup

      @id = "test_object_1"
      @revisions = @adapter.send :revisions

      @remover = mock GOM::Storage::CouchDB::Remover, :perform => nil
      GOM::Storage::CouchDB::Remover.stub :new => @remover
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

  describe "#count" do

    before :each do
      @adapter.setup

      @counter = mock GOM::Storage::CouchDB::Counter, :perform => 1
      GOM::Storage::CouchDB::Counter.stub :new => @counter
    end

    it "should initialize the counter" do
      GOM::Storage::CouchDB::Counter.should_receive(:new).with(@database).and_return(@counter)
      @adapter.count
    end

    it "should perform a count" do
      @counter.should_receive(:perform)
      @adapter.count
    end

    it "should return the count" do
      count = @adapter.count
      count.should == 1
    end

  end

  describe "#collection" do

    before :each do
      @adapter.setup

      @view = mock CouchDB::Design::View
      @views = mock Hash, :[] => @view
      @design.stub :views => @views

      @options = mock Hash

      @fetcher = mock GOM::Storage::CouchDB::Collection::Fetcher
      GOM::Storage::CouchDB::Collection::Fetcher.stub :new => @fetcher

      @collection = mock GOM::Object::Collection
      GOM::Object::Collection.stub :new => @collection
    end

    it "should select the right view" do
      @views.should_receive(:[]).with("test_view").and_return(@view)
      @adapter.collection :test_view, @options
    end

    it "should raise #{described_class::ViewNotFoundError} if the view name is invalid" do
      @views.stub :[] => nil
      lambda do
        @adapter.collection :test_view, @options
      end.should raise_error(described_class::ViewNotFoundError)
    end

    it "should initialize a collection fetcher" do
      GOM::Storage::CouchDB::Collection::Fetcher.should_receive(:new).with(@view, @adapter.revisions, @options).and_return(@fetcher)
      @adapter.collection :test_view, @options
    end

    it "should initialize a collection with the fetcher" do
      GOM::Object::Collection.should_receive(:new).with(@fetcher, "test_storage").and_return(@collection)
      @adapter.collection :test_view, @options
    end

    it "should return the collection" do
      collection = @adapter.collection :test_view, @options
      collection.should == @collection
    end

  end

  describe "#clear_revisions" do

    before :each do
      @adapter.revisions[:test] = "value"
    end

    it "should clear the revisions hash" do
      @adapter.clear_revisions!
      @adapter.revisions.should be_empty
    end

  end

end
