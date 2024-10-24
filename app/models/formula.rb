class Formula < ApplicationRecord
  belongs_to :metric
  has_one :project, through: :metric
  # after_commit :update_project_values, on: %i(update)
  # before_update :update_dependents
  before_update :refresh_dependents
  before_destroy :delete_calcs
  include Relatable

  # def components
  #   body.gsub(/\#\{\d*\}/) do |match|
  #     Metric.find(match[/\d*/].to_i).name
  #   end
  # end

  def components
    r = /\#\{\d+\:\d+\}/
    body.scan(r)&.map!{|e| e.scan(/\d+/)}
  end

  def components_was
    r = /\#\{\d+\:\d+\}/
    body_was&.scan(r)&.map!{|e| e.scan(/\d+/)}
  end

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
    # values = p.values
    p.periods.each do |period|
      p.assign_dependents(metric, period)
      # return if values["#{metric.id}"]["#{period.id}"]["entry"]
      # values["#{metric.id}"]["#{period.id}"]["calc"] = calc(period, values)
    end
    p.save

    # project.update(values: values)
  end

  def calc(period, values)
    na = false
    output = body.gsub(/\#\{\d+\:\d+\}/) do |match|
      c = Component.new(match)
      e = values.dig("#{c.id}", "#{period.offset(c.period)&.id}")
      e ? e["input"] || e["calc"] : na = true
    end
    return if na
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
      values["#{metric.id}"]["#{period_id}"]["calc"] = nil if values&.dig("#{metric.id}", "#{period_id}", "calc")
    end
    metric.project.update(values: values)
  end

  def remove_dependents
    output = metric.project.values
    components_was
  end

  def update_dependents
    regex = /(\#\{\d+\:\d+\})/
    output = project.values
    periods = project.periods

    periods.each do |p|
      components_was&.each do |c|
        output["#{c[0]}"]["#{p.id}"]["dependents"].delete("#{metric.id}")
      end
    end

    periods.each do |p|
      components&.each do |c|
        # binding.pry
        if p.offset(-c[1].to_i)
          if output.dig("#{c[0]}", "#{p.id}", "dependents", "#{metric.id}")
            output["#{c[0]}"]["#{p.id}"]["dependents"]["#{metric.id}"] << p.offset(-c[1].to_i).id.to_s
          else
            output["#{c[0]}"]["#{p.id}"]["dependents"]["#{metric.id}"] = [ p.offset(-c[1].to_i).id.to_s ]
          end
        end
      end
    end

    project.update(values: output)
  end



  def component_ids
    r = /\#\{\d+\:/
    body.scan(r)&.map!{|e| e.scan(/\d+/)}&.flatten&.map!{|e| e.to_i}&.uniq
  end

  def component_ids_were
    r = /\#\{\d+\:/
    body_was&.scan(r)&.map!{|e| e.scan(/\d+/)}&.flatten&.map!{|e| e.to_i}&.uniq
  end

  def remove_from_dependents
    m = metric.entries.pluck(:id)
    entries = Entry.where(metric_id: component_ids_were)
    # binding.pry
    entries.each do |e|
      e.dependents.delete_if{|d| d.to_i.in?(m)}
      e.save_without_calc
    end
  end

  def update_related_entries
    @self_entries = Entry.where(metric: metric)
    Entry.where(metric: metric).each do |e|
      e.formula_body = self.body
      e.save_without_calc
    end
  end

  def refresh_dependents
    remove_from_dependents
    update_related_entries
    Entry.where(metric_id: component_ids).includes(:period).each do |e|
      components.select{|i| i[0] == e.metric_id.to_s}.each do |c|
        if e.date.prev_month(-c[1].to_i)
          d = @self_entries.find_by(metric: metric, date: e.date.prev_month(-c[1].to_i))
          e.dependents << d.id.to_s if d
          e.dependents = e.dependents.uniq
          e.save_without_calc
        end
      end
    end
  end
end
