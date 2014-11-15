# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: lazy_records 0.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "lazy_records"
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Kingsley Hendrickse"]
  s.date = "2014-11-15"
  s.description = "port of lazy records to ruby"
  s.email = "kingsley.hendrickse@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "lazy_records.gemspec",
    "lazy_store.gemspec",
    "lib/adapters/mssql.rb",
    "lib/adapters/mysql.rb",
    "lib/adapters/sqlite3.rb",
    "lib/definition.rb",
    "lib/keyword.rb",
    "lib/lazy_records.rb",
    "lib/memory_records.rb",
    "lib/predicate_to_sql.rb",
    "lib/predicates.rb",
    "lib/record.rb",
    "lib/sql_records.rb",
    "lib/sql_virtual_records.rb",
    "spec/memory_records_spec.rb",
    "spec/spec_helper.rb",
    "spec/sql_records_spec.rb",
    "spec/sql_virtual_records_spec.rb",
    "spec/test_data/.keep"
  ]
  s.homepage = "http://github.com/kingsleyh/lazy_records"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "port of lazy records to ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<totally_lazy>, [">= 0"])
      s.add_runtime_dependency(%q<lock_method>, [">= 0"])
      s.add_runtime_dependency(%q<encrypted_strings>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0.0.rc1"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<totally_lazy>, [">= 0"])
      s.add_dependency(%q<lock_method>, [">= 0"])
      s.add_dependency(%q<encrypted_strings>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 3.0.0.rc1"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<totally_lazy>, [">= 0"])
    s.add_dependency(%q<lock_method>, [">= 0"])
    s.add_dependency(%q<encrypted_strings>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 3.0.0.rc1"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

