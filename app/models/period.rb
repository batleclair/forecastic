class Period < ApplicationRecord
  belongs_to :project
  has_many :entries, dependent: :destroy

  def offset(i=0)
    i == 0 ? self : Period.find_by(project: self.project, date: self.date.prev_month(i))
  end
end
