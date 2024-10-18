class Row < ApplicationRecord
  acts_as_list
  belongs_to :section
  belongs_to :metric
  has_many :entries, ->{order 'date ASC'}, through: :metric
end
