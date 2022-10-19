class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :courses do |t|
      t.text :name, null: false
      t.timestamps
    end
    add_index :courses, :name, unique: true
  end
end
