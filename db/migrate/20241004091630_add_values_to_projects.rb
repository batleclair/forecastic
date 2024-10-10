class AddValuesToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :values, :json, default: {}
  end
end
