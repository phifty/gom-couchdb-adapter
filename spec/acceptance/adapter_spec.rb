require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "couchdb-adapter"))

GOM::Storage::Configuration.read File.join(File.dirname(__FILE__), "..", "storage.configuration")

describe "couchdb adapter" do

  it_should_behave_like "an adapter connected to a stateful storage"

end
