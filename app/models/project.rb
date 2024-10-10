class Project < ApplicationRecord
  has_many :sheets, -> { order(position: :asc) }, dependent: :destroy
  has_many :periods, dependent: :destroy
  has_many :metrics, dependent: :destroy

  validates :name, presence: {message: "Name required"}

  after_create :initialize_default

  include Loopable

  def value_for(metric, period)
    values["#{metric.id}"]["#{period.id}"]["input"] || values["#{metric.id}"]["#{period.id}"]["calc"]
  end

  def value_is(metric, period)
    if values["#{metric.id}"]["#{period.id}"]["input"]
      "input"
    elsif values["#{metric.id}"]["#{period.id}"]["calc"]
      "calc"
    else
      nil
    end
  end

  def value_is_calc?(metric, period)
    value_is(metric, period) == "calc"
  end

  def value_is_input?(metric, period)
    value_is(metric, period) == "input"
  end

  def assign(metric, period, input)
    output = self.values
    values["#{metric.id}"]["#{period.id}"]["input"] = input.presence
    self.assign_attributes(values: output)
  end

  def assign_dependents(metric, period)
    @looper = {"#{metric.id}": {"#{period.id}": 1}}
    assign_dependents_loop(metric, period)
  end

  def assign_dependents_loop(metric, period)
    output = values
    metric.dependencies.each do |d|
      if @looper.dig(:"#{d.id}", :"#{period.id}")
        return
      else
        @looper.merge!({"#{d.id}": {"#{period.id}": 1}})
        output["#{d.id}"]["#{period.id}"]["calc"] = d.formula.calc(period, values)
        self.assign_attributes(values: output)
        assign_dependents_loop(d, period)
      end
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
