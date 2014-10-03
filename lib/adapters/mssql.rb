require 'tiny_tds'

class Mssql

  def initialize(details)
    @client = TinyTds::Client.new(details)
  end

  def query(sql)
   @client.execute(sql)
  end

  def fields(table)
    query('select * from ' + table.to_s).fields
  end

end

