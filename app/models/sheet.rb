class Sheet < ApplicationRecord
  acts_as_list
  belongs_to :project
  has_many :sections, -> { order(position: :asc) }, dependent: :destroy
  has_many :rows, through: :sections
  after_create :auto_name
  # before_destroy :one_sheet_required

  private

  def auto_name
    update(name: "Sheet_#{id}")
  end

  def one_sheet_required
    Sheet.create(project: project) if project.sheets.count == 1
  end
end
