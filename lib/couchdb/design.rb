require File.expand_path(File.join(File.dirname(__FILE__), "..", "transport", "json"))
require File.join(File.dirname(__FILE__), "document")

module CouchDB

  # The Design class acts as a wrapper for CouchDB design documents.
  class Design < Document

    autoload :View, File.join(File.dirname(__FILE__), "design", "view")

    attr_accessor :language
    attr_reader :views

    def initialize(database, id, language = "javascript")
      super database
      self.id, self.language = id, language
      @views = ViewsProxy.new self
    end

    def id
      super.sub /^_design\//, ""
    end

    def id=(value)
      super "_design/#{value}"
    end

    def language
      self["language"]
    end

    def language=(value)
      self["language"] = value
    end

    private

    # A proxy class for the views property.
    class ViewsProxy

      def initialize(design)
        @design = design
        @design["views"] = { }
      end

      def <<(view)
        @design["views"].merge! view.to_hash
      end

      def [](name)
        Design::View.new name, @design["views"][name]["map"], @design["views"][name]["reduce"]
      end

    end

  end

end
