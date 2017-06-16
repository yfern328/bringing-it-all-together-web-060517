class Dog

  attr_accessor :name, :breed, :id

  def initialize(breed:, name:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    dog_hash = {}
    dog_hash[:id] = row[0]
    dog_hash[:name] = row[1]
    dog_hash[:breed] = row[2]
    dog = Dog.new(dog_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(dog_hash)
    dog = Dog.new(dog_hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, id).flatten)
  end

  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed]).flatten
    row.empty? ? self.create(dog_hash) : self.new_from_db(row)
  end

end
