class Formula < ApplicationRecord
  belongs_to :metric
  has_one :project, through: :metric
  after_commit :update_project_values, on: %i(update)
  before_destroy :delete_calcs
  include Relatable

  # def components
  #   body.gsub(/\#\{\d*\}/) do |match|
  #     Metric.find(match[/\d*/].to_i).name
  #   end
  # end

  def to_a
    regex = /(\#\{\d+\:\d+\})|([\(\)\*\^\+\-\/])|(\d+\.?\d*)/
    body.split(regex).reject(&:empty?) unless body.nil?
  end

  def output_array
    return if body.nil?
    a = []
    to_a.each {|e| a << Component.new(e)}
    a
  end

  def contains?(metric)
    body.match?(/\#\{#{metric.id}\}/)
  end

  def scan_for(metric)
    body.scan(/\#\{#{metric.id}\:\d+\}/).uniq.map{|e| Component.new(e)}
  end

  def update_project_values
    p = project
    values = p.values
    p.periods.each do |period|
      p.assign_dependents(metric, period)
      # return if values["#{metric.id}"]["#{period.id}"]["entry"]
      # values["#{metric.id}"]["#{period.id}"]["calc"] = calc(period, values)
    end
    p.save

    # project.update(values: values)
  end

  def calc(period, values)
    output = body.gsub(/\#\{\d+\:\d+\}/) do |match|
      c = Component.new(match)
      e = values.dig("#{c.id}", "#{period.offset(c.period)&.id}")
      e["input"] || e["calc"] if e
    end
    begin
      eval(output)
    rescue SyntaxError, StandardError => e
      Rails.logger.error("Eval failed in calc method: #{e.message}")
      nil
    end
  end

  # def insert_at(position)
  #   self.body = to_a.insert(position.to_i, to_a.last)[0..-2].join if position
  # end

  def delete_calcs
    values = metric.project.values
    metric.project.periods.pluck(:id).each do |period_id|
      values["#{metric.id}"]["#{period_id}"]["calc"] = nil
    end
    metric.project.update(values: values)
  end
end
