require 'sqlite3'

class Sqlite3

  def initialize(database,show_sql=false)
    @client =  SQLite3::Database.new(database)
    @client.results_as_hash=true
    @show_sql = show_sql
  end

  def query(sql)
    puts sql if @show_sql
    @client.execute(sql)
  end

  def fields(table)
    query('select * from ' + table.to_s).fields
  end

end


