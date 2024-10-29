class Entry < ApplicationRecord
  attr_accessor :still
  belongs_to :period
  belongs_to :metric
  has_one :formula, through: :metric
  has_one :project, through: :metric
  before_create :set_date
  after_update :update_dependents, unless: :still

  @@calculations = {}

  def still!
    self.still = true
  end

  def save_without_calc
    self.still!
    self.save
  end

  def set_date
    self.date = period.date
  end

  def all_dependents(visited = {}, sorted = [])
    return sorted if visited[self.id] == :sorted

    raise 'Circular dependency detected' if visited[self.id] == :ongoing

    visited[self.id] = :ongoing
    dependent_entries = Entry.where(id: self.dependents)
    dependent_entries.each do |dep|
      dep.all_dependents(visited, sorted)
    end
    visited[self.id] = :sorted

    sorted << self
    sorted
  end


  def update_dependents
    @@calculations.clear
    updates = {}
    sorted_dependents = (all_dependents - [self]).reverse
    all_precedent_ids = sorted_dependents.flat_map(&:precedent_ids).uniq
    precedents_hash = Entry.where(id: all_precedent_ids).index_by(&:id)
    sorted_dependents.each do |e|
      result = e.calculate(precedents_hash)
      updates[e.id] = result unless e.calc_was == result
    end

    if updates.any?
      sql_cases = updates.map { |id, calc| "WHEN #{id} THEN #{calc ? ActiveRecord::Base.connection.quote(calc) : 0}" }.join(' ')
      Entry.where(id: updates.keys).update_all("calc = CASE id #{sql_cases} END")
    end
  end

  def precedent_ids
    formula_body&.scan(/\#\{\d+\}/)&.map{|e| e[/\d+/]}
  end

  def precedents
    Entry.where(id: precedent_ids)
  end

  def calculate(precedents_hash)

    return @@calculations[self.id] if @@calculations.key?(self.id)

    na = false
    output = "#{formula_body}"

    precedent_ids&.each do |precedent_id|
      p = precedents_hash[precedent_id.to_i]
      r = p&.value || @@calculations[p&.id] || p&.calc
      na = true unless r
      output = output.gsub(/\#\{(#{p&.id})\}/, r.to_s)
    end

    if na
      return nil
    else
      begin
        result = eval(output)
        @@calculations[self.id] = result
        result
      rescue SyntaxError, StandardError => e
        Rails.logger.error("Cannot calculate #{self.id} based on formula #{output}")
        nil
      end
    end
  end
end
