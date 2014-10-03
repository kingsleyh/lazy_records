module LazyRecords

  def record(*data)
    Record.new(sequence(data).in_pairs.map { |r| {r.key.name => r.value} }.reduce({}) { |a, b| a.merge(b) })
  end

  class Record < OpenStruct

    def get_hash
      self.instance_variable_get("@table")
    end

    def get_keywords
      get_hash.keys
    end

    def get_values
      get_hash.values
    end

  end

end