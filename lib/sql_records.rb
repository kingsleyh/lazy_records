module LazyRecords

  class SqlRecords

    def initialize(connection)
      @c = connection
      @predicate_to_sql = PredicateToSql.new
    end

    def add(definition, records)
      raise(UnsupportedTypeException.new, "records must be of type: #{Sequence}<#{Record}> but was: #{records.class}") unless records.is_a?(Sequences::Sequence)
      excludes = definition.add_exclusions.get_or_else(empty).map(&:name)
      records.each do |r|
        data = r.get_hash.reject { |k, v| excludes.contains?(k) }
        sql = 'insert into ' + definition.name.to_s + " (#{data.keys.join(',')}) values (#{data.values.map(&:inspect).join(',')})"
        @c.query(sql)
      end
    end

    def get(definition, selection=nil)
      sql = option(selection).is_some? ? 'select * from ' + definition.name.to_s + ' where ' + @predicate_to_sql.convert(selection) :
            'select * from ' + definition.name.to_s
      sequence(@c.query(sql).map { |r| Record.new(r) })
    end

    def set(definition, selection, *updates)
      pending_fields = Maps.merge(sequence(updates).in_pairs.map { |e| {e.key.name.to_sym => e.value} })
      sql = 'update ' + definition.name.to_s + ' set ' + pending_fields.map { |k, v| "#{k}='#{v}'" }.join(',') + ' where ' + @predicate_to_sql.convert(selection)
      sequence(@c.query(sql))
    end

    def remove(definition, selection=nil)
      sql = option(selection).is_some? ? 'delete from ' + definition.name.to_s + ' where ' + @predicate_to_sql.convert(selection) : 'delete from ' + definition.name.to_s
      sequence(@c.query(sql))
    end

    def inner_join(def1, def2, keyword_map)
      sql = 'select ' + process_columns(def1, def2) + ' from ' + def1.name.to_s + ' inner join ' + def2.name.to_s + ' on ' + process_keywords(keyword_map, def1, def2)
      sql_query(sql)
    end

    def sql_query(sql)
      sequence(@c.query(sql).map { |r| Record.new(r) })
    end

    private

    def process_keywords(keyword_map, d1, d2)
      keyword_map.map { |k, v| d1.name.to_s + ".#{k.name} = " + d2.name.to_s + ".#{v.name}" }.to_a.join(' and ')
    end

    def process_columns(d1, d2)
      one = d1.columns_as_list.map{|k| " #{d1.name}.#{k} as '#{d1.name}_#{k}'"}.join(',')
      two = d2.columns_as_list.map{|k| " #{d2.name}.#{k} as '#{d2.name}_#{k}'"}.join(',')
      one + two
    end

  end

end
