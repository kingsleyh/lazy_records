module LazyRecords

  class MemoryRecords

    def initialize
      @store = empty
    end

    def add(definition, records)
      raise(UnsupportedTypeException.new, "records must be of type: #{Sequence}<#{Record}> but was: #{records.class}") unless records.is_a?(Sequences::Sequence)
      table = @store.filter(where(key: equals(definition.name)))
      if table.empty?
        @store = @store.join(sequence(pair(definition.name, records)))
      else
        remaining_tables = @store.reject(where(key: equals(definition.name)))
        updated_table = table.update(value: table.head.value.join(records))
        @store = remaining_tables.join(updated_table)
      end
    end

    def get(definition, selection=nil)
      if selection
        @store.filter(where(key: equals(definition.name))).send(:filter, selection).map { |row| row.value }.head
      else
        @store.filter(where(key: equals(definition.name))).map { |row| row.value }.head
      end
    end

    def set(definition, selection, *updates)
      table = @store.filter(where(key: equals(definition.name)))
      updated = get(definition).send(:filter, selection).update(Maps.merge(sequence(updates).in_pairs.map { |e| {e.key.name.to_sym => e.value} }))
      remaining = get(definition).send(:reject, selection)
      records = remaining.join(updated)
      remaining_tables = @store.reject(where(key: equals(definition.name)))
      updated_table = table.update(value: records)
      @store = remaining_tables.join(updated_table)
    end

    def remove_definition(definition)
      name = definition.is_a?(Symbol) ? definition : definition.name
      @store = @store.reject(where(key: equals(name)))
    end

    def remove(definition, selection)
      table = @store.filter(where(key: equals(definition.name)))
      records = get(definition).send(:reject, selection)
      remaining_tables = @store.reject(where(key: equals(definition.name)))
      updated_table = table.update(value: records)
      @store = remaining_tables.join(updated_table)
    end

    def inner_join(def1, def2, keyword_map)
      get(def1).flat_map { |d1| get(def2).filter { |d2| process_keywords(keyword_map, d1, d2) }.map { |n| Record.new(process_columns(def1, def2, d1.get_hash, n.get_hash)) } }
    end

    def process_keywords(keyword_map, d1, d2)
      eval(keyword_map.map { |k, v| "d1.send(:#{k.name}) == d2.send(:#{v.name})" }.to_a.join(' and '))
    end

    def process_columns(d1, d2, h1, h2)
      one = h1.map { |k, v| {"#{d1.name}_#{k}" => v} }.reduce({}) { |a, b| a.merge(b) }
      two = h2.map { |k, v| {"#{d2.name}_#{k}" => v} }.reduce({}) { |a, b| a.merge(b) }
      one.merge(two)
    end


    def as_lock
      'lazy_store'
    end

    def read_data(location)
      if File.exists?(location)
        f = File.open(location)
        @store = deserialize(Marshal.load(f))
      end
    end

    lock_method :read_data

    def write_data(location)
      f = File.new(location, 'w')
      Marshal.dump(@store.serialize, f)
      f.close
    end

    lock_method :write_data

  end

end



