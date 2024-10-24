class Entry < ApplicationRecord
  attr_accessor :still
  belongs_to :period
  belongs_to :metric
  has_one :formula, through: :metric
  has_one :project, through: :metric
  before_create :set_date
  after_update :update_dependents, unless: :still

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

  # def self.set_cache(hash)
  #   self.cached_hash = hash
  #   Rails.cache.write('entries', hash)
  # end

  # starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  # ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  # p elapsed = "#{((ending - starting)*1000).round(2)}ms to perform"

  def update_dependents
    entries = Entry.where(id: self.dependents)
    entries.each do |e|
      result = e.calculate
      unless e.calc_was == result
        # Entry.cached_hash[e.metric_id][e.date][:calc] = result
        e.update(calc: result)
      end
    end
  end

  def update_formula
    updated_formula_body = formula_body&.gsub(/\#\{\d+\:\d+\}/) do |match|
      p = match.partition(":")
      m = p.first[/\d+/].to_i
      d = p.last[/\d+/].to_i
      e = Entry.find_by(metric_id: m, date: date.prev_month(d))
      e ? "\#{#{e.id}}" : return
    end
    update(formula_body: updated_formula_body)
  end

  def precedent_ids
    formula_body.scan(/\#\{\d+\}/).map{|e| e[/\d+/]}
  end

  def precedents
    Entry.where(id: precedent_ids)
  end

  # def precedents
  #   a = []
  #   formula_body&.gsub(/\#\{\d+\:\d+\}/) do |match|
  #     m = match.partition(":").first[/\d+/].to_i
  #     p = match.partition(":").last[/\d+/].to_i
  #     a << Entry.find_by(metric_id: m, date: date.prev_month(p))
  #   end
  #   a
  # end

  def reset_formula
    body = formula&.body
    body&.gsub!(/\#\{\d+\:\d+\}/) do |match|
      m = match.partition(":").first[/\d+/].to_i
      d = match.partition(":").last[/\d+/].to_i
      e = Entry.find_by(metric_id: m, date: date.prev_month(d))
      e ? "\#{#{e.id}}" : return
    end
    still!
    update(formula_body: body) if body != formula_body
  end

  def calculate
    na = false
    output = "#{formula_body}"
    precedents.each do |p|
      r = p.value || p.calc
      na = true unless r
      output = output.gsub(/\#\{(#{p.id})\}/, r.to_s)
    end
    if na
      return
    else
      begin
        eval(output)
      rescue SyntaxError, StandardError => e
        Rails.logger.error("Cannot calculate #{self.id} based on formula #{output}")
        nil
      end
    end
  end

  # def calculate
  #   na = false
  #   output = formula_body&.gsub(/\#\{\d+\:\d+\}/) do |match|
  #     m = match.partition(":").first[/\d+/].to_i
  #     p = match.partition(":").last[/\d+/].to_i
  #     # e = Entry.cached_hash[m][date.prev_month(p)]
  #     # e ? e[:value] || e[:calc] : na = true
  #     e = Entry.find_by(metric_id: m, date: date.prev_month(p))
  #     e ? e.value || e.calc : na = true
  #   end
  #   if na
  #     return
  #   else
  #     begin
  #       eval(output)
  #     rescue SyntaxError, StandardError => e
  #       Rails.logger.error("Cannot calculate #{self.id} based on formula #{output}")
  #       nil
  #     end
  #   end
  # end
end
