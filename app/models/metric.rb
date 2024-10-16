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
  after_create :add_to_project_values
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

  private

  def add_to_project_values
    project.values[:"#{id}"] = {}
    project.periods.each do |period|
      project.values[:"#{id}"][:"#{period.id}"] = {
        input: nil,
        calc: nil
      }
    end
    project.save
  end

  def remove_from_project_values
    updated_values = project.values&.delete("#{id}")
    project.update(values: updated_values)
  end
end
