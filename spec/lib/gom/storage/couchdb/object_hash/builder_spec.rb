require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::ObjectHash::Builder do

  before :each do
    @document = mock CouchDB::Document, :id => "test_document_1", :[] => "Object", :each => nil

    @builder = described_class.new @document
  end

  describe "object_hash" do

    it "should set the id" do
      object_hash = @builder.object_hash
      object_hash.should include(:id => "test_document_1")
    end

    it "should set the class" do
      object_hash = @builder.object_hash
      object_hash.should include(:class => "Object")
    end

    it "should transfer each property" do
      @document.stub(:each).and_yield("test", "test value")
      object_hash = @builder.object_hash
      object_hash.should include(:properties => { :test => "test value" })
    end

    it "should transfer each relation" do
      @document.stub(:each).and_yield("test_id", "test_storage:test_object_2")
      object_hash = @builder.object_hash
      object_hash[:relations][:test].should be_instance_of(GOM::Object::Proxy)
    end

  end

end
