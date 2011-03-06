require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "spec_helper"))

describe GOM::Storage::CouchDB::Counter do

  before :each do
    @database = mock CouchDB::Database, :information => { "doc_count" => 1 }

    @counter = described_class.new @database
  end

  describe "perform" do

    it "should fetch database information" do
      @counter.perform
    end

    it "should return the document count" do
      count = @counter.perform
      count.should == 1
    end

  end

end
