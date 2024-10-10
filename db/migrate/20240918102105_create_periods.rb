class CreatePeriods < ActiveRecord::Migration[7.0]
  def change
    create_table :periods do |t|
      t.references :project, null: false, foreign_key: true
      t.date :date

      t.timestamps
    end
  end
end
