class Formula < ApplicationRecord
  belongs_to :metric
  has_one :project, through: :metric
  before_update :update_entries
  before_destroy :delete_calcs
  include Relatable

  def components
    r = /\#\{\d+\:\d+\}/
    body.scan(r)&.map!{|e| e.scan(/\d+/)} || []
  end

  def components_was
    r = /\#\{\d+\:\d+\}/
    body_was&.scan(r)&.map!{|e| e.scan(/\d+/)} || []
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

  # def insert_at(position)
  #   self.body = to_a.insert(position.to_i, to_a.last)[0..-2].join if position
  # end

  def component_ids
    r = /\#\{\d+\:/
    body.scan(r)&.map!{|e| e.scan(/\d+/)}&.flatten&.map!{|e| e.to_i}&.uniq
  end

  def component_ids_were
    r = /\#\{\d+\:/
    body_was&.scan(r)&.map!{|e| e.scan(/\d+/)}&.flatten&.map!{|e| e.to_i}&.uniq
  end

  def update_entries

    precedent_updates = {}

    all = (components_was + components).uniq
    all_ids = all.map{ |i| i[0] }
    precedent_entries = Entry.where(metric_id: all_ids)

    self_entries = metric.entries
    entry_ids = self_entries.pluck(:id)

    precedent_entries.each do |e|
      e.dependents.delete_if{|d| d.to_i.in?(entry_ids)}
      components&.select{|i| i[0].to_i == e.metric_id}&.each do |i|
        entry = self_entries.find{|s| s.date == e.date.prev_month(-i[1].to_i)}
        e.dependents << entry.id.to_s unless entry.nil?
      end
      precedent_updates[e.id] = e.dependents
    end

    precedent_updates.each do |entry_id, new_dependents|
      Entry.where(id: entry_id).update_all(dependents: new_dependents)
    end

    self_entries.each do |e|
      formula_body = "#{self.body}"
      result = formula_body&.gsub(/\#\{\d+\:\d+\}/) do |match|
        m = match.partition(":").first[/\d+/].to_i
        d = match.partition(":").last[/\d+/].to_i
        output = precedent_entries.find{ |pe| pe.metric_id == m && pe.date == e.date.prev_month(d) }
        output ? "\#{#{output&.id}}" : "na"
      end
      result = nil if result.include?("na")
      e.still!
      e.update(formula_body: result)
    end

  end

end
