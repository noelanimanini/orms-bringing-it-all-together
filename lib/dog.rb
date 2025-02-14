class Dog
    attr_accessor :name, :breed, :id
    def initialize (name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY, 
            name TEXT,
            color TEXT,
            breed TEXT, 
            instagram TEXT 
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs; 
        SQL
        DB[:conn].execute(sql)
    end 

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def save 
        sql = <<-SQL
    INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    #Dog #save saves an instance of the dog class to the database and then sets the given dogs `id` attribute
    self 
    #Dog #save returns an instance of the dog class (self recall)

    end 

    def self.create(name:, breed:)
        dog1 = self.new(name: name, breed: breed)
        dog1.save
        dog1 
    end 

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end 

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

        if !dog.empty?
            dog_data  = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else 
            dog = self.create(name: name, breed: breed)
        end 
        dog
    end 

    #paste this code into google doc^

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
            FROM dogs
            WHERE name = ?
        SQL
        
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end 

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? "
        DB[:conn].execute(sql, self.name, self.breed)
    end 


end 