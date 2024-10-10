class CreateSheets < ActiveRecord::Migration[7.0]
  def change
    create_table :sheets do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.integer :rank

      t.timestamps
    end
  end
end
