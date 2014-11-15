module LazyRecords

  def record(*data)
    Record.new(sequence(data).in_pairs.map { |r| {r.key.name => r.value} }.reduce({}) { |a, b| a.merge(b) })
  end

  def vrecord(*data)
    Record.new(sequence(data).in_pairs.map { |r| {r.key => r.value} }.reduce({}) { |a, b| a.merge(b) })
  end

  class Record < OpenStruct

    def initialize(hash=nil)
      @table = {}
      if hash
        hash.each_pair do |k, v|
          k = k.to_s.to_sym
          @table[k] = v
          new_ostruct_member(k)
        end
      end
    end

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