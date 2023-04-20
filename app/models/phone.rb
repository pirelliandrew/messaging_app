class Phone < ApplicationRecord
  validates :blacklist, presence: true, default: false
  validates :number,
            presence: true,
            uniqueness: true,
            format: { with: /\A\d+\z/, message: "only allows numbers" }
end