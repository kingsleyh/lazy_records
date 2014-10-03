module LazyRecords

  def definition(name, *columns)
    Definition.new(name, columns)
  end

  class Definition

    attr_reader :name, :columns

    def initialize(name, *columns)
      @name = name
      @columns = columns
      @client = none
      @add_exclusions = none
      @show_sql = false
    end

    def columns_as_list
      columns.first.map(&:name)
    end

    def add_exclusions=(*values)
      @add_exclusions = sequence(values.flatten)
    end

    def add_exclusions
      option(@add_exclusions)
    end

    def suggest_keywords(connection)
      fields = connection.fields(@name)
      keywords = fields.map { |field| "#{field} = keyword(:#{field})" }.join("\n")
      puts keywords
      puts "#{@name} = definition(:#{@name}, #{fields.join(', ')})"
    end

  end

end