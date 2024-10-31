class AddPeriodSettingsToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :periodicity, :integer, default: 1
    add_column :projects, :first_end, :date, default: Date.new(Date.today.year, 12)
  end
end
