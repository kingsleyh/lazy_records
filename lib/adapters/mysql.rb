require 'mysql2'

class Mysql

  def initialize(details,show_sql=false)
    @client =  Mysql2::Client.new(details)
    @show_sql = show_sql
  end

  def query(sql)
    puts sql if @show_sql
    @client.query(sql)
  end

  def fields(table)
    query('select * from ' + table.to_s).fields
  end

end


