class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :label, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :due_date
      t.integer :priority, default: 1
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
