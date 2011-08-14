
# Builds a javascript map-reduce-view out of a property view.
class GOM::Storage::CouchDB::View::BuilderFromProperty

  def initialize(property_view)
    @property_view = property_view
  end

  def map_reduce_view
    build_conditions
    build_emits
    build_emit_string

    GOM::Storage::Configuration::View::MapReduce.new(
      "function(document) {\n  if (#{@conditions.join(" && ")}) {\n    emit(#{@emit_string}, null);\n  }\n}",
      nil
    )
  end

  private

  def build_conditions
    @conditions = [ ]
    @property_view.filter.each do |property_name, condition|
      @conditions << condition(condition.first, property_name, condition.last)
    end
  end

  def build_emits
    @emits = [ @property_view.properties ].flatten.compact.map do |property|
      "document['#{property}']"
    end
  end

  def build_emit_string
    @emit_string = case @emits.length
      when 0
        "null"
      when 1
        @emits.first
      else
        "[ " + @emits.join(", ") + " ]"
    end
  end

  def condition(kind, property_name, value)
    case kind
      when :equals
        "document['#{property_name}'] == " + (value.is_a?(String) ? "'#{value}'" : value.to_s)
      when :greater_than
        "document['#{property_name}'] > " + (value.is_a?(String) ? "'#{value}'" : value.to_s)
      else
        raise ArgumentError, "the specified condition kind '#{kind}' is not supported"
    end
  end

end
