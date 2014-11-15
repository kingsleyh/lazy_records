require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MemoryRecords do

  before(:each) do
    @records = MemoryRecords.new
    @records.remove_definition(:people)
  end

  it 'should return empty if there are no records' do
    name = keyword(:name)
    age = keyword(:age)
    people = definition(:people, name, age)
    expect(@records.get(people)).to eq(empty)
  end

  it 'should add records' do
    name = keyword(:name)
    age = keyword(:age)
    people = definition(:people, name, age)

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

    @records.add(people, sequence(
        record(name, 'kostas', age, 25)))

    @records.add(people, sequence(
        record(name, 'kings', age, 34)))

    @records.set(people, where(name: equals('kostas')), age, 35)
    expect(@records.get(people).filter(where(name: equals('kostas'))).head.age).to eq(35)
  end

  it 'should filter records' do
    name = keyword(:name)
    age = keyword(:age)
    people = definition(:people, name, age)

    @records.add(people, sequence(
        record(name, 'kostas', age, 25),
        record(name, 'andrew', age, 26),
        record(name, 'david', age, 27),
        record(name, 'mike', age, 28),
        record(name, 'kings', age, 29)))


    expect(@records.get(people).filter(where name: matches(/k/)).count).to eq(3)
  end

  it 'should remove records' do
    name = keyword(:name)
    age = keyword(:age)
    people = definition(:people, name, age)

    @records.add(people, sequence(
        record(name, 'andrew', age, 25),
        record(name, 'kostas', age, 26),
    ))

    @records.remove(people, where(name: equals('andrew')))
    expect(@records.get(people).head).to eq(record(name, 'kostas', age, 26))

  end

  it 'should write to file' do
    name = keyword(:name)
    age = keyword(:age)
    people = definition(:people, name, age)

    @records.add(people, sequence(
        record(name, 'kostas', age, 25),
        record(name, 'kings', age, 34)))

    @records.write_data(File.dirname(__FILE__) + '/test_data/people.db')
  end

  it 'should read from file' do
    name = keyword(:name)
    age = keyword(:age)
    people = definition(:people, name, age)
    @records.read_data(File.dirname(__FILE__) + '/test_data/people.db')
    expect(@records.get(people).count).to eq(2)
  end

  it 'should inner join' do
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
        record(people_id, 2, people_name, 'Khilan',  people_age, 25, people_address, 'Delhi',  people_salary, 1500.00, order_order_id, 101, order_id, 2, order_date, '2012', order_amount, 1560),
        record(people_id, 3, people_name, 'kaushik', people_age, 23, people_address, 'Kota',   people_salary, 2000.00, order_order_id, 102, order_id, 3, order_date, '2014', order_amount, 3000),
        record(people_id, 3, people_name, 'kaushik', people_age, 23, people_address, 'Kota',   people_salary, 2000.00, order_order_id, 100, order_id, 3, order_date, '2013', order_amount, 1500),
        record(people_id, 4, people_name, 'Chaitali',people_age, 25, people_address, 'Mumbai', people_salary, 6500.00, order_order_id, 103, order_id, 4, order_date, '2012', order_amount, 2060)
    )
    expect(@records.inner_join(people, orders, id => id).entries).to eq(expected.entries)
  end

  def data_for_joins
    id = keyword(:id)
    name = keyword(:name)
    age = keyword(:age)
    address = keyword(:address)
    salary = keyword(:salary)
    people = definition(:people, id, name, age)

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

    orders_list = sequence(
        record(order_id, 102, id, 3, date, '2014', amount, 3000),
        record(order_id, 100, id, 3, date, '2013', amount, 1500),
        record(order_id, 101, id, 2, date, '2012', amount, 1560),
        record(order_id, 103, id, 4, date, '2012', amount, 2060)
    )

    @records.add(orders, orders_list)
  end


end
