class CreateEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :entries do |t|
      t.references :period, null: false, foreign_key: true
      t.references :metric, null: false, foreign_key: true
      t.float :value

      t.timestamps
    end
  end
end
