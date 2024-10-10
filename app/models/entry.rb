class Entry < ApplicationRecord
  belongs_to :period
  belongs_to :metric
end
