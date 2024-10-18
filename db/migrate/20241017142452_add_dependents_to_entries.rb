class AddDependentsToEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :dependents, :text, array: true, default: []
    add_column :entries, :calc, :float
  end
end
