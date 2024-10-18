class Entry < ApplicationRecord
  attr_accessor :still
  belongs_to :period
  belongs_to :metric
  has_one :formula, through: :metric
  before_create :set_date
  after_update :update_dependents, unless: :still

  def save_without_calc
    self.still = true
    self.save
  end

  def set_date
    self.date = period.date
  end

  def self.update_formula_and_date
    all.each do |e|
      e.date = e.period.date
      e.formula_body = e.formula&.body
      e.save
    end
  end

  def update_dependents
    entries = Entry.where(id: self.dependents)
    entries.each do |e|
      e.update(calc: e.calculate) unless e.calc_was == e.calculate
    end
  end

  def calculate
    na = false
    output = formula_body&.gsub(/\#\{\d+\:\d+\}/) do |match|
      m = match.partition(":").first[/\d+/].to_i
      p = match.partition(":").last[/\d+/].to_i
      e = Entry.find_by(metric_id: m, date: date.prev_month(p))
      e ? e.value || e.calc : na = true
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
end
