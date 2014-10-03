require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SqlRecords do

  before(:each) do
    @c = double("DbConnection")
    @records = SqlRecords.new(@c)
  end

  it 'should add records' do
    name = keyword(:name)
    age = keyword(:age)
    people = definition(:people, name, age)

    allow(@c).to receive(:query).with('insert into people (name,age) values ("kostas",25)')
    allow(@c).to receive(:query).with('insert into people (name,age) values ("kings",34)')
    allow(@c).to receive(:query).with('select * from people') {
      [record(name, 'kostas', age, 25), record(name, 'kings', age, 34)]
    }

    @records.add(people, sequence(
        record(name, 'kostas', age, 25),
        record(name, 'kings', age, 34)))


    expect(@records.get(people).count).to eq(2)
    expect(@records.get(people).head.name).to eq('kostas')
  end

  it 'should update records with set' do
    name = keyword(:name)
    age = keyword(:age)
    people = definition(:people, name, age)

    allow(@c).to receive(:query).with('insert into people (name,age) values ("kostas",25)')
    allow(@c).to receive(:query).with('insert into people (name,age) values ("kings",34)')
    allow(@c).to receive(:query).with("update people set age='35' where name = 'kostas'")
    allow(@c).to receive(:query).with('select * from people') {
      [record(name, 'kostas', age, 35), record(name, 'kings', age, 34)]
    }

    @records.add(people, sequence(
        record(name, 'kostas', age, 25)))

    @records.add(people, sequence(
        record(name, 'kings', age, 34)))

    @records.set(people, where(name: equals('kostas')), age, 35)
    expect(@records.get(people).filter(where(name: equals('kostas'))).head.age).to eq(35)
  end


  it 'should remove records' do
    name = keyword(:name)
    age = keyword(:age)
    people = definition(:people, name, age)

    allow(@c).to receive(:query).with('insert into people (name,age) values ("andrew",25)')
    allow(@c).to receive(:query).with('insert into people (name,age) values ("kostas",26)')
    allow(@c).to receive(:query).with("delete from people where name = 'andrew'")
    allow(@c).to receive(:query).with('select * from people') {
      [record(name, 'kostas', age, 26)]
    }

    @records.add(people, sequence(
        record(name, 'andrew', age, 25),
        record(name, 'kostas', age, 26),
    ))

    @records.remove(people, where(name: equals('andrew')))
    expect(@records.get(people).head).to eq(record(name, 'kostas', age, 26))

  end

  it 'should filter records' do
     name = keyword(:name)
     age = keyword(:age)
     people = definition(:people, name, age)

     allow(@c).to receive(:query).with('insert into people (name,age) values ("kostas",25)')
     allow(@c).to receive(:query).with('insert into people (name,age) values ("andrew",26)')
     allow(@c).to receive(:query).with('insert into people (name,age) values ("david",27)')
     allow(@c).to receive(:query).with('insert into people (name,age) values ("mike",28)')
     allow(@c).to receive(:query).with('insert into people (name,age) values ("kings",29)')

     @records.add(people, sequence(
         record(name, 'kostas', age, 25),
         record(name, 'andrew', age, 26),
         record(name, 'david', age, 27),
         record(name, 'mike', age, 28),
         record(name, 'kings', age, 29)))

     allow(@c).to receive(:query).with("select * from people where name like '%k%'") {
           [record(name, 'kostas', age, 25),
            record(name, 'mike', age, 28),
            record(name, 'kings', age, 29)]
         }

     expect(@records.get(people,where(name: like('%k%'))).count).to eq(3)
   end

  it 'should support inner join' do
    data_for_joins

    id = keyword(:id)
    name = keyword(:name)
    age = keyword(:age)
    order_id = keyword(:order_id)
    date = keyword(:date)
    amount = keyword(:amount)

    people = definition(:people, id, name, age)
    orders = definition(:orders, order_id, id, date, amount)

    people_id = keyword(:people_id)
    people_name = keyword(:people_name)
    people_age = keyword(:people_age)
    people_address = keyword(:people_address)
    people_salary = keyword(:people_salary)
    order_id = keyword(:orders_id)
    order_order_id = keyword(:orders_order_id)
    order_date = keyword(:orders_date)
    order_amount = keyword(:orders_amount)

    expected = sequence(
        record(people_id, 2, people_name, 'Khilan', people_age, 25, people_address, 'Delhi', people_salary, 1500.00, order_order_id, 101, order_id, 2, order_date, '2012', order_amount, 1560),
        record(people_id, 3, people_name, 'kaushik', people_age, 23, people_address, 'Kota', people_salary, 2000.00, order_order_id, 102, order_id, 3, order_date, '2014', order_amount, 3000),
        record(people_id, 3, people_name, 'kaushik', people_age, 23, people_address, 'Kota', people_salary, 2000.00, order_order_id, 100, order_id, 3, order_date, '2013', order_amount, 1500),
        record(people_id, 4, people_name, 'Chaitali', people_age, 25, people_address, 'Mumbai', people_salary, 6500.00, order_order_id, 103, order_id, 4, order_date, '2012', order_amount, 2060)
    )

    allow(@c).to receive(:query).with("select  people.id as 'people_id', people.name as 'people_name', people.age as 'people_age' orders.order_id as 'orders_order_id', orders.id as 'orders_id', orders.date as 'orders_date', orders.amount as 'orders_amount' from people inner join orders on people.id = orders.id") {
      [record(people_id, 2, people_name, 'Khilan', people_age, 25, people_address, 'Delhi', people_salary, 1500.00, order_order_id, 101, order_id, 2, order_date, '2012', order_amount, 1560),
       record(people_id, 3, people_name, 'kaushik', people_age, 23, people_address, 'Kota', people_salary, 2000.00, order_order_id, 102, order_id, 3, order_date, '2014', order_amount, 3000),
       record(people_id, 3, people_name, 'kaushik', people_age, 23, people_address, 'Kota', people_salary, 2000.00, order_order_id, 100, order_id, 3, order_date, '2013', order_amount, 1500),
       record(people_id, 4, people_name, 'Chaitali', people_age, 25, people_address, 'Mumbai', people_salary, 6500.00, order_order_id, 103, order_id, 4, order_date, '2012', order_amount, 2060)]
    }

    expect(@records.inner_join(people, orders, id => id).entries).to eq(expected.entries)
  end


  def data_for_joins
    id = keyword(:id)
    name = keyword(:name)
    age = keyword(:age)
    address = keyword(:address)
    salary = keyword(:salary)
    people = definition(:people, id, name, age)

    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (1,"Ramesh",32,"Ahmedabad",2000.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (2,"Khilan",25,"Delhi",1500.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (3,"kaushik",23,"Kota",2000.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (4,"Chaitali",25,"Mumbai",6500.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (5,"Hardik",27,"Bhopal",8500.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (6,"Komal",22,"MP",4500.0)')
    allow(@c).to receive(:query).with('insert into people (id,name,age,address,salary) values (7,"Muffy",24,"Indore",10000.0)')

    people_list = sequence(
        record(id, 1, name, 'Ramesh', age, 32, address, 'Ahmedabad', salary, 2000.00),
        record(id, 2, name, 'Khilan', age, 25, address, 'Delhi', salary, 1500.00),
        record(id, 3, name, 'kaushik', age, 23, address, 'Kota', salary, 2000.00),
        record(id, 4, name, 'Chaitali', age, 25, address, 'Mumbai', salary, 6500.00),
        record(id, 5, name, 'Hardik', age, 27, address, 'Bhopal', salary, 8500.00),
        record(id, 6, name, 'Komal', age, 22, address, 'MP', salary, 4500.00),
        record(id, 7, name, 'Muffy', age, 24, address, 'Indore', salary, 10000.00)
    )

    @records.add(people, people_list)


    order_id = keyword(:order_id)
    date = keyword(:date)
    amount = keyword(:amount)

    orders = definition(:orders, order_id, id, date, amount)

    allow(@c).to receive(:query).with('insert into orders (order_id,id,date,amount) values (102,3,"2014",3000)')
    allow(@c).to receive(:query).with('insert into orders (order_id,id,date,amount) values (100,3,"2013",1500)')
    allow(@c).to receive(:query).with('insert into orders (order_id,id,date,amount) values (101,2,"2012",1560)')
    allow(@c).to receive(:query).with('insert into orders (order_id,id,date,amount) values (103,4,"2012",2060)')

    orders_list = sequence(
        record(order_id, 102, id, 3, date, '2014', amount, 3000),
        record(order_id, 100, id, 3, date, '2013', amount, 1500),
        record(order_id, 101, id, 2, date, '2012', amount, 1560),
        record(order_id, 103, id, 4, date, '2012', amount, 2060)
    )

    @records.add(orders, orders_list)
  end


end
