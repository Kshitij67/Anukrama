class CreateLabels < ActiveRecord::Migration[8.0]
  def change
    create_table :labels do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
    add_index :labels, :name, unique: true
  end
end
