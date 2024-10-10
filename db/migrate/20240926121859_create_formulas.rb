class CreateFormulas < ActiveRecord::Migration[7.0]
  def change
    create_table :formulas do |t|
      t.references :metric, null: false, foreign_key: true
      t.string :body

      t.timestamps
    end
  end
end
