class Section < ApplicationRecord
  acts_as_list
  belongs_to :sheet
  before_create :auto_name
  has_many :rows, -> { order(position: :asc) }, dependent: :destroy
  has_one :project, through: :sheet

  private

  def auto_name
    assign_attributes(name: "NewSection")
  end
end
