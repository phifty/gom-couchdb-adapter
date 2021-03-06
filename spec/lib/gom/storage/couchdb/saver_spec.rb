require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Saver do

  before :each do
    @database = mock CouchDB::Database
    @draft = GOM::Object::Draft.new "object_1"
    @revisions = { "object_1" => 1 }
    @storage_name = "test_storage"

    @saver = described_class.new @database, @draft, @revisions, @storage_name
  end

  describe "perform" do

    before :each do
      @document = mock CouchDB::Document, :[]= => nil, :id= => nil, :save => true, :id => "object_1", :rev => 2, :rev= => nil
      CouchDB::Document.stub(:new).and_return(@document)
    end

    it "should initialize a document" do
      CouchDB::Document.should_receive(:new).with(@database).and_return(@document)
      @saver.perform
    end

    it "should set the id" do
      @document.should_receive(:id=).with("object_1")
      @saver.perform
    end

    it "should set the revision" do
      @document.should_receive(:rev=).with(1)
      @saver.perform
    end

    it "should not set the id or revision if not included in the draft" do
      @document.should_not_receive(:id=)
      @document.should_not_receive(:rev=)
      @draft.object_id = nil
      @saver.perform
    end

    it "should save the document" do
      @document.should_receive(:save).and_return(true)
      @saver.perform
    end

    it "should store the revision" do
      @saver.perform
      @revisions.should == { "object_1" => 2 }
    end

    it "should return the (new) object id" do
      @saver.perform
      @saver.object_id.should == "object_1"
    end

    context "draft with properties" do

      before :each do
        @draft.properties = { :test => "test value" }
      end

      it "should set the properties" do
        @document.should_receive(:[]=).with("test", "test value")
        @saver.perform
      end

    end

    context "draft with relations" do

      before :each do
        @related_object = Object.new
        @related_object_id = mock GOM::Object::Id, :to_s => "test_storage:object_2"
        @related_object_proxy = mock GOM::Object::Proxy, :id => @related_object_id, :object => @related_object

        GOM::Storage.stub(:store)
        GOM::Object.stub(:id).and_return(@related_object_id)

        @draft.relations = { :related_object => @related_object_proxy }
      end

      it "should set the relations" do
        @document.should_receive(:[]=).with("related_object_id", "test_storage:object_2")
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

  end

end
