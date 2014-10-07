module LazyRecords

  class SqlVirtualRecords

    def initialize(connection)
      @c = connection
      @predicate_to_sql = PredicateToSql.new
    end

    def add(table_name, records)
      records.each do |r|
        sql = 'insert into ' + table_name.to_s + " (#{r.get_hash.keys.to_a.join(',')}) values (#{r.get_hash.values.map(&:inspect).to_a.join(',')})"
        @c.query(sql)
      end
    end

    def get(table_name, selection=nil)
      sql = option(selection).is_some? ? 'select * from ' + table_name.to_s + ' where ' + @predicate_to_sql.convert(selection) :
            'select * from ' + table_name.to_s
      sequence(@c.query(sql).map { |r| Record.new(r) })
    end

    def set(table_name, selection, *updates)
      pending_fields = Maps.merge(sequence(updates).in_pairs.map { |e| {e.key => e.value} })
      sql = 'update ' + table_name.to_s + ' set ' + pending_fields.map { |k, v| "#{k}='#{v}'" }.join(',') + ' where ' + @predicate_to_sql.convert(selection)
      sequence(@c.query(sql))
    end

    def remove(table_name, selection=nil)
      sql = option(selection).is_some? ? 'delete from ' + table_name.to_s + ' where ' + @predicate_to_sql.convert(selection) : 'delete from ' + table_name.to_s
      sequence(@c.query(sql))
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
