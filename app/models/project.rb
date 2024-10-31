class Project < ApplicationRecord
  has_many :sheets, -> { order(position: :asc) }, dependent: :destroy
  has_many :periods, -> { where.not(date: nil).order(date: :asc) }, dependent: :destroy
  has_many :metrics, dependent: :destroy
  has_many :entries, through: :metrics
  before_destroy -> { fixed_period.destroy }
  enum :periodicity, { monthly: 1, quarterly: 3, yearly: 12 }, suffix: true

  validates :name, presence: {message: "Name required"}

  after_create :initialize_default

  def fixed_period
    Period.find_by(project_id: id, date: nil)
  end

  def p_factor
    Project.periodicities[periodicity]
  end

  private

  def initialize_default
    Sheet.create(project_id: id, name: "Sheet1")
    for i in 1..12 do
      Period.create(project_id: id, date: Date.new(Date.today.year, i))
    end
    Period.create(project_id: id, date: nil)
  end

end


class Project < ApplicationRecord
  has_many :periods, -> { where.not(date: nil).order(date: :asc) }, dependent: :destroy
end
