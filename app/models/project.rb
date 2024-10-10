class Project < ApplicationRecord
  has_many :sheets, -> { order(position: :asc) }, dependent: :destroy
  has_many :periods, dependent: :destroy
  has_many :metrics, dependent: :destroy

  validates :name, presence: {message: "Name required"}

  after_create :initialize_default

  def value_for(metric, period)
    values["#{metric.id}"]["#{period.id}"]["input"] || values["#{metric.id}"]["#{period.id}"]["calc"]
  end

  def assign_value(metric, period, input)
    output = self.values
    values["#{metric.id}"]["#{period.id}"]["input"] = input.presence
    self.assign_attributes(values: output)
  end

  def assign_dependents(metric, period)
    output = self.values
    metric.dependencies.each do |d|
      return if output["#{d.id}"]["#{period.id}"]["entry"]
      output["#{d.id}"]["#{period.id}"]["calc"] = d.formula.calc(period, values)
      self.assign_attributes(values: output)
      assign_dependents(d, period) unless d.formula.contains?(metric)
    end
  end

  private

  def initialize_default
    Sheet.create(project_id: id, name: "Sheet1")
    for i in 1..12 do
      Period.create(project_id: id, date: Date.new(Date.today.year, i))
    end
  end

end
