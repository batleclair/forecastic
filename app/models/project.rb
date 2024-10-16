class Project < ApplicationRecord
  has_many :sheets, -> { order(position: :asc) }, dependent: :destroy
  has_many :periods, dependent: :destroy
  has_many :metrics, dependent: :destroy

  validates :name, presence: {message: "Name required"}

  after_create :initialize_default

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
    @output = values
    assign_dependents_loop(metric, period)
    self.assign_attributes(values: @output)
  end

  def assign_dependents_loop(metric, period)
    metric.dependents_on(period).each do |m, p|
      loop = @looper.dig(:"#{m.id}", :"#{p&.id}") || 0
      if loop > 10 || p.nil?
        return
      else
        @looper.merge!({"#{m.id}": {"#{p.id}": loop += 1}})
        @output["#{m.id}"]["#{p.id}"]["calc"] = m.formula&.calc(p, @output)
        assign_dependents_loop(m, p)
      end
    end
  end

  private

  def initialize_default
    Sheet.create(project_id: id, name: "Sheet1")
    for i in 1..2 do
      Period.create(project_id: id, date: Date.new(Date.today.year, i))
    end
  end

end
