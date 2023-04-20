class Phone < ApplicationRecord
  validates :number,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A\d+\z/, message: "only allows numbers" }
end