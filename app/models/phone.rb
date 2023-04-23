# frozen_string_literal: true

class Phone < ApplicationRecord
  validates :number,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A\d+\z/, message: 'for phone only allows numbers' }

  def blacklisted?
    blacklist
  end
end
