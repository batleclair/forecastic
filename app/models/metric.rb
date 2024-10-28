class Metric < ApplicationRecord
  belongs_to :project
  has_many :rows, dependent: :destroy
  has_many :sections, through: :rows
  has_one :formula, dependent: :destroy
  has_many :entries, dependent: :destroy
  validates :name, presence: {message: "Name required"}
  include PgSearch::Model
  include Relatable
  pg_search_scope :search_by_name, against: :name, using: { tsearch: {prefix: true} }
  # after_create :add_to_project_values
  after_save :add_or_remove_entries
  after_destroy :remove_from_project_values

  def dependencies
    Metric.joins(:formula).where("body LIKE ?", "%" + "\#\{#{self.id}\:" + "%").includes(:formula)
  end

  def dependents_on(period)
    dependents = Metric.joins(:formula).where("body LIKE ?", "%" + "\#\{#{self.id}\:" + "%").includes(:formula)
    a = {}
    dependents.each do |d|
      d.formula.scan_for(self).each {|e| a[d] = period.offset(- e.period) }
    end
    a
  end

  def add_or_remove_entries
    if fixed
      entries.where.not(date: nil).each{|e| e&.destroy}
      Entry.create(metric_id: id, period_id: project.fixed_period.id)
    else
      Entry.find_by(metric_id: id, period_id: project.fixed_period.id)&.destroy
      project.periods.each { |p| Entry.create(metric: self, period: p) }
    end
  end

  private

  def add_to_project_values
    # project.values[:"#{id}"] = {}
    # project.periods.each do |period|
    #   project.values[:"#{id}"][:"#{period.id}"] = {
    #     input: nil,
    #     calc: nil
    #   }
    # end
    # project.save

    output = project.values
    output["#{id}"] = {}
    project.periods.each { |p| output["#{id}"]["#{p.id}"] = Dependent.new }
    project.update(values: output)
  end

  def remove_from_project_values
    updated_values = project.values&.delete("#{id}")
    project.update(values: updated_values)
  end
end
