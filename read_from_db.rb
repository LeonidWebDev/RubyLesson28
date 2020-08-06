# row  is array here(in Database)
def readDB
  db = SQLite3::Database.new "barbershop.db"
  db.results_as_hash = true
  db.execute 'select * from Users order by id desc' do |row| 
    print row['username']
    print "\t-\t"
    puts row['datestamp']
    puts "-----------------"
  end
end