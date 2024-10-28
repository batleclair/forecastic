class AddFixedToMetrics < ActiveRecord::Migration[7.0]
  def change
    add_column :metrics, :fixed, :boolean
  end
end
