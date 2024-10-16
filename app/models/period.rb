class Period < ApplicationRecord
  belongs_to :project
  has_many :entries, dependent: :destroy

  def offset(i=0)
    Period.find_by(project: self.project, date: self.date.prev_month(i))
  end
end
