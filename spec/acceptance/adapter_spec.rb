require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "gom", "couchdb-adapter"))

describe "couchdb adapter" do

  it_should_behave_like "an adapter connected to a stateful storage"

end
