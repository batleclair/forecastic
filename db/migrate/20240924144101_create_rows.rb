class CreateRows < ActiveRecord::Migration[7.0]
  def change
    create_table :rows do |t|
      t.references :section, null: false, foreign_key: true
      t.references :metric, null: false, foreign_key: true
      t.integer :position
      t.boolean :anchor

      t.timestamps
    end
  end
end
