class Formula < ApplicationRecord
  belongs_to :metric
  after_commit :update_project_values, on: %i(update)
  # before_destroy :delete_calcs

  # def components
  #   body.gsub(/\#\{\d*\}/) do |match|
  #     Metric.find(match[/\d*/].to_i).name
  #   end
  # end

  def to_a
    regex = /(\#\{\d*\})|([\(\)\*\^\+\-\/])|(\d+\.?\d*)/
    body.split(regex).reject(&:empty?) unless body.nil?
  end

  def output_array
    to_a.map {|e| e.match(/\#\{\d*\}/) ? Metric.find(e[/\d+/].to_i).name : e } unless body.nil?
  end

  # def process(period)
  #   errors = []
  #   output = body.gsub(/\#\{\d*\}/) do |match|
  #     metric = Metric.find(match[/\d+/].to_i)
  #     entry = Entry.find_by(metric: metric, period: period)
  #     if entry&.value
  #       entry.value
  #     elsif metric.formula
  #       if metric.formula.contains?(self.metric) || metric.formula.process(period).nil?
  #         errors << "na"
  #       else
  #         metric.formula&.process(period)
  #       end
  #     else
  #       errors << "na"
  #     end
  #   end
  #   errors.empty? ? eval(output) : nil
  # end

  def contains?(metric)
    body.match?(/\#\{#{metric.id}\}/)
  end

  def update_project_values
    project = metric.project
    values = project.values
    update_project(values)
    project.update(values: values)
  end

  # def update_project(values, period)
  #   # periods = metric.project.periods
  #   # periods.each do |period|
  #     return if values["#{metric.id}"]["#{period.id}"]["entry"]
  #     values["#{metric.id}"]["#{period.id}"]["calc"] = calc(period, values)
  #   # end
  #   values
  # end

  def calc(period, values)
    output = body.gsub(/\#\{\d*\}/) do |match|
      values["#{match[/\d+/]}"]["#{period.id}"]["input"] || values["#{match[/\d+/].to_i}"]["#{period.id}"]["calc"]
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
    values
  end
end
