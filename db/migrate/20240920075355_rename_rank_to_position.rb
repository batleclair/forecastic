class RenameRankToPosition < ActiveRecord::Migration[7.0]
  def change
    rename_column :sheets, :rank, :position
  end
end
