require "pry"

class Student
  attr_accessor :id, :name, :grade

  # def initialize(id, name, grade)
  #   @id = id
  #   @name = name
  #   @grade = grade
  # end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)

    @id = DB[:conn].execute("
      SELECT last_insert_rowid()
      FROM students
      ")[0][0]
  end

  def self.new_from_db(row)
    new_student = Student.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

  def self.find_by_name(name)
    # binding.pry
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name == ?;
    SQL

    row = DB[:conn].execute(sql, name)
    Student.new_from_db(row[0])
    #binding.pry
  end

  def self.all_students_in_grade_9
    #binding.pry
    DB[:conn].execute("SELECT * FROM students WHERE grade == 9;")
  end

  def self.students_below_12th_grade
    below_12th = DB[:conn].execute("SELECT * FROM students WHERE grade < 12;")
    new_student_array = [ ]
    below_12th.each { |row| new_student_array << Student.new_from_db(row) }
    new_student_array
  end

  def self.all
    all = DB[:conn].execute("SELECT * FROM STUDENTS;")
    new_student_array = []
    all.each do |row|
      new_student_array << Student.new_from_db(row)
    end
    new_student_array
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.first_X_students_in_grade_10(x)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade == 10
      LIMIT ?
    SQL

    all = DB[:conn].execute(sql, x)
    new_student_array = [ ]
    all.each  { |row| new_student_array << Student.new_from_db(row) }
    new_student_array
  end

  def self.first_student_in_grade_10
    new_student = DB[:conn].execute("SELECT * FROM students WHERE grade == 10 LIMIT 1;")
    Student.new_from_db(new_student[0])
  end

  def self.all_students_in_grade_X(x)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade == ?;
    SQL
    all = DB[:conn].execute(sql, x)
    new_student_array = [ ]
    all.each { |row| new_student_array << Student.new_from_db(row)}
    new_student_array
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
