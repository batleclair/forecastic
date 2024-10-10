class Row < ApplicationRecord
  acts_as_list
  belongs_to :section
  belongs_to :metric
end
