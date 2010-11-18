require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Saver do

  before :each do
    @database = mock CouchDB::Database
    @object_hash = { :id => "test_object_1" }
    @revisions = mock Hash, :[]= => nil
    @relation_storage_name = "test_storage"

    @saver = described_class.new @database, @object_hash, @revisions, @relation_storage_name
  end

  describe "perform" do

    before :each do
      @document = mock CouchDB::Document, :[]= => nil, :id= => nil, :save => true, :id => "test_object_1", :rev => 1
      CouchDB::Document.stub(:new).and_return(@document)
    end

    it "should initialize a document" do
      CouchDB::Document.should_receive(:new).with(@database).and_return(@document)
      @saver.perform
    end

    context "object hash with properties" do

      before :each do
        @object_hash.merge! :properties => { :test => "test value" }
      end

      it "should set the properties" do
        @document.should_receive(:[]=).with("test", "test value")
        @saver.perform
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
        @saver.perform
      end

      it "should store the related object if it hasn't an id" do
        GOM::Storage.should_receive(:store).with(@related_object, "test_storage")
        GOM::Object.should_receive(:id).with(@related_object).and_return(@related_object_id)

        @related_object_proxy.stub(:id).and_return(nil)
        @related_object_proxy.stub(:object).and_return(@related_object)

        @saver.perform
      end

    end

    it "should set the id" do
      @document.should_receive(:id=).with("test_object_1")
      @saver.perform
    end

    it "should not set the id if not included in the object hash" do
      @document.should_not_receive(:id=)
      @object_hash.delete :id
      @saver.perform
    end

    it "should save the document" do
      @document.should_receive(:save).and_return(true)
      @saver.perform
    end

    it "should store the revision" do
      @revisions.should_receive(:[]=).with("test_object_1", 1)
      @saver.perform
    end

    it "should return the (new) object id" do
      @saver.perform
      @saver.id.should == "test_object_1"
    end

  end

end
