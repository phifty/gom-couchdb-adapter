require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::View::Builder do

  before :each do
    @class_view = mock GOM::Storage::Configuration::View::Class, :class_name => "Object"

    @builder = described_class.new @class_view
  end

  describe "map_reduce_view" do

    it "should return a map reduce view that emits all the documents of the given model class" do
      view = @builder.map_reduce_view
      view.should be_instance_of(GOM::Storage::Configuration::View::MapReduce)
      view.map.should == "function(document) {\n  if (document['model_class'] == 'Object') {\n    emit(document['_id'], null);\n  }\n}"
      view.reduce.should be_nil
    end

  end

end
