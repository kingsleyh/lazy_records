# PLEASE NOTE - This project is not being actively maintained at the moment - I am taking a break - not sure when I will return.

# Lazy Records for Ruby

This is a port of the java functional library [Lazy Records](https://code.google.com/p/totallylazy/) to the ruby language. It still needs a lot of tidy and re-working in several places. But it works and is a first cut.


### Summary

* Tries to be as lazy as possible
* Supports method chaining
* Is primarily based on totally lazy

### Install

This gem requires ruby 2.x.x

In your bundler Gemfile

```ruby
 gem lazy_records, '~>0.0.1' 
```

Or with rubygems

```
 gem install lazy_records
```

### Examples

The following are some simple examples of the currently implemented functionality.

With MemoryRecords (Run in memory only)

```ruby
require 'lazy_records'

name = keyword(:name)
age = keyword(:age)
people = definition(:people, name, age)

records = MemoryRecords.new

records.add(people, sequence(
record(name, 'kostas', age, 25),
record(name, 'kings', age, 34)))

records.get(people).count # returns 2
records.get(people).head.name) # returns 'kostas'

```

with SqlRecords (Run against either mysql or mssql currently)

```ruby
require 'lazy_records'
require 'adpaters/mysql'

name = keyword(:name)
age = keyword(:age)
people = definition(:people, name, age)

records = SqlRecords.new(Mysql.new(username:'user1',password:'pass1',database:'mydb'))

records.add(people, sequence(
record(name, 'kostas', age, 25),
record(name, 'kings', age, 34)))

records.get(people).count # returns 2
records.get(people).head.name) # returns 'kostas'

```
