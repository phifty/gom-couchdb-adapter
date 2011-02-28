require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Draft::Builder do

  before :each do
    @document = mock CouchDB::Document, :id => "test_document_1", :[] => "Object", :each => nil

    @builder = described_class.new @document
  end

  describe "draft" do

    it "should set the object id" do
      draft = @builder.draft
      draft.object_id.should == "test_document_1"
    end

    it "should set the class" do
      draft = @builder.draft
      draft.class_name.should == "Object"
    end

    it "should transfer each property" do
      @document.stub(:each).and_yield("test", "test value")
      draft = @builder.draft
      draft.properties.should == { :test => "test value" }
    end

    it "should transfer each relation" do
      @document.stub(:each).and_yield("test_id", "test_storage:test_object_2")
      draft = @builder.draft
      draft.relations[:test].should be_instance_of(GOM::Object::Proxy)
    end

  end

end
