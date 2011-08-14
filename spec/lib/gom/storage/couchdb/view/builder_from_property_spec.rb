require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::View::BuilderFromProperty do

  before :each do
    @view = mock GOM::Storage::Configuration::View::Property,
                 :filter => { :model_class => [ :equals, "GOM::Spec::Object" ], :number => [ :greater_than, 13 ] },
                 :properties => [ :_id, :number ]

    @builder = described_class.new @view
  end

  describe "map_reduce_view" do

    it "should return a map reduce view that emits the correct data" do
      view = @builder.map_reduce_view
      view.should be_instance_of(GOM::Storage::Configuration::View::MapReduce)
      view.map.should == "function(document) {\n  if (document['model_class'] == 'GOM::Spec::Object' && document['number'] > 13) {\n    emit([ document['_id'], document['number'] ], null);\n  }\n}"
      view.reduce.should be_nil
    end

  end

end
