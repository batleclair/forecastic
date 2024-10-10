class Period < ApplicationRecord
  belongs_to :project
  has_many :entries, dependent: :destroy
end
