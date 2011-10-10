require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::View::BuilderForAll do

  before :each do
    @all_view = mock GOM::Storage::Configuration::View::All

    @builder = described_class.new @class_all
  end

  describe "map_reduce_view" do

    it "should return a map reduce view that emits all the documents with a model_class attribute" do
      view = @builder.map_reduce_view
      view.should be_instance_of(GOM::Storage::Configuration::View::MapReduce)
      view.map.should == "function(document) {\n  if (document['model_class']) {\n    emit(document['_id'], null);\n  }\n}"
      view.reduce.should be_nil
    end

  end

end
