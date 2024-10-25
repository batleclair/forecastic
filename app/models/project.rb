class Project < ApplicationRecord
  has_many :sheets, -> { order(position: :asc) }, dependent: :destroy
  has_many :periods, dependent: :destroy
  has_many :metrics, dependent: :destroy
  has_many :entries, through: :metrics

  validates :name, presence: {message: "Name required"}

  after_create :initialize_default

  private

  def initialize_default
    Sheet.create(project_id: id, name: "Sheet1")
    for i in 1..12 do
      Period.create(project_id: id, date: Date.new(Date.today.year, i))
    end
  end

end
