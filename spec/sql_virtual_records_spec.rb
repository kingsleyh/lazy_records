require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SqlVirtualRecords do

  before(:each) do
    @c = double("DbConnection")
    @records = SqlVirtualRecords.new(@c)
  end

  it 'should add records' do
    allow(@c).to receive(:query).with('insert into people (name,age) values ("kostas",25)')
    allow(@c).to receive(:query).with('insert into people (name,age) values ("kings",34)')
    allow(@c).to receive(:query).with('select * from people') {
      [vrecord(:name, 'kostas', :age, 25), vrecord(:name, 'kings', :age, 34)]
    }

    @records.add(:people, sequence(
        vrecord(:name, 'kostas', :age, 25),
        vrecord(:name, 'kings', :age, 34)))


    expect(@records.get(:people).count).to eq(2)
    expect(@records.get(:people).head.name).to eq('kostas')
  end

  it 'should update records with set' do
    allow(@c).to receive(:query).with('insert into people (name,age) values ("kostas",25)')
    allow(@c).to receive(:query).with('insert into people (name,age) values ("kings",34)')
    allow(@c).to receive(:query).with("update people set age='35' where name = 'kostas'")
    allow(@c).to receive(:query).with('select * from people') {
      [vrecord(:name, 'kostas', :age, 35), vrecord(:name, 'kings', :age, 34)]
    }

    @records.add(:people, sequence(
        vrecord(:name, 'kostas', :age, 25)))

    @records.add(:people, sequence(
        vrecord(:name, 'kings', :age, 34)))

    @records.set(:people, where(name: equals('kostas')), :age, 35)
    expect(@records.get(:people).filter(where(name: equals('kostas'))).head.age).to eq(35)
  end


  it 'should remove records' do
    allow(@c).to receive(:query).with('insert into people (name,age) values ("andrew",25)')
    allow(@c).to receive(:query).with('insert into people (name,age) values ("kostas",26)')
    allow(@c).to receive(:query).with("delete from people where name = 'andrew'")
    allow(@c).to receive(:query).with('select * from people') {
      [vrecord(:name, 'kostas', :age, 26)]
    }

    @records.add(:people, sequence(
        vrecord(:name, 'andrew', :age, 25),
        vrecord(:name, 'kostas', :age, 26),
    ))

    @records.remove(:people, where(name: equals('andrew')))
    expect(@records.get(:people).head).to eq(vrecord(:name, 'kostas', :age, 26))

  end

  it 'should filter records' do

    allow(@c).to receive(:query).with('insert into people (name,age) values ("kostas",25)')
    allow(@c).to receive(:query).with('insert into people (name,age) values ("andrew",26)')
    allow(@c).to receive(:query).with('insert into people (name,age) values ("david",27)')
    allow(@c).to receive(:query).with('insert into people (name,age) values ("mike",28)')
    allow(@c).to receive(:query).with('insert into people (name,age) values ("kings",29)')

    @records.add(:people, sequence(
        vrecord(:name, 'kostas', :age, 25),
        vrecord(:name, 'andrew', :age, 26),
        vrecord(:name, 'david', :age, 27),
        vrecord(:name, 'mike', :age, 28),
        vrecord(:name, 'kings', :age, 29)))

    allow(@c).to receive(:query).with("select * from people where name like '%k%'") {
      [vrecord(:name, 'kostas', :age, 25),
       vrecord(:name, 'mike', :age, 28),
       vrecord(:name, 'kings', :age, 29)]
    }

    expect(@records.get(:people, where(name: like('%k%'))).count).to eq(3)
  end

  it 'should support sql query' do
    data_for_joins

    expected = sequence(
        vrecord(:name, 'Khilan', :amount, 1560),
        vrecord(:name, 'kaushik', :amount, 3000),
        vrecord(:name, 'kaushik', :amount, 1500),
        vrecord(:name, 'Chaitali', :amount, 2060)
    )

    allow(@c).to receive(:query).with("select people.name, orders.amount from people inner join orders on orders.id = people.id") {
      [vrecord(:name, 'Khilan', :amount, 1560),
       vrecord(:name, 'kaushik', :amount, 3000),
       vrecord(:name, 'kaushik', :amount, 1500),
       vrecord(:name, 'Chaitali', :amount, 2060)]
    }

    expect(@records.sql_query("select people.name, orders.amount from people inner join orders on orders.id = people.id").entries).to eq(expected.entries)
  end


  def data_for_joins
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (1,"Ramesh",32,"Ahmedabad",2000.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (2,"Khilan",25,"Delhi",1500.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (3,"kaushik",23,"Kota",2000.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (4,"Chaitali",25,"Mumbai",6500.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (5,"Hardik",27,"Bhopal",8500.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (6,"Komal",22,"MP",4500.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (7,"Muffy",24,"Indore",10000.0)')

    people_list = sequence(
        vrecord(:id, 1, :name, 'Ramesh', :age, 32, :address, 'Ahmedabad', :salary, 2000.00),
        vrecord(:id, 2, :name, 'Khilan', :age, 25, :address, 'Delhi', :salary, 1500.00),
        vrecord(:id, 3, :name, 'kaushik', :age, 23, :address, 'Kota', :salary, 2000.00),
        vrecord(:id, 4, :name, 'Chaitali', :age, 25, :address, 'Mumbai', :salary, 6500.00),
        vrecord(:id, 5, :name, 'Hardik', :age, 27, :address, 'Bhopal', :salary, 8500.00),
        vrecord(:id, 6, :name, 'Komal', :age, 22, :address, 'MP', :salary, 4500.00),
        vrecord(:id, 7, :name, 'Muffy', :age, 24, :address, 'Indore', :salary, 10000.00)
    )

    @records.add(:people, people_list)

    allow(@c).to receive(:query).with('insert into orders (order_id,id,date,amount) values (102,3,"2014",3000)')
    allow(@c).to receive(:query).with('insert into orders (order_id,id,date,amount) values (100,3,"2013",1500)')
    allow(@c).to receive(:query).with('insert into orders (order_id,id,date,amount) values (101,2,"2012",1560)')
    allow(@c).to receive(:query).with('insert into orders (order_id,id,date,amount) values (103,4,"2012",2060)')

    orders_list = sequence(
        vrecord(:order_id, 102, :id, 3, :date, '2014', :amount, 3000),
        vrecord(:order_id, 100, :id, 3, :date, '2013', :amount, 1500),
        vrecord(:order_id, 101, :id, 2, :date, '2012', :amount, 1560),
        vrecord(:order_id, 103, :id, 4, :date, '2012', :amount, 2060)
    )

    @records.add(:orders, orders_list)
  end


end
