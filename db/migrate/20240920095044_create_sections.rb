class CreateSections < ActiveRecord::Migration[7.0]
  def change
    create_table :sections do |t|
      t.string :name
      t.references :sheet, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
