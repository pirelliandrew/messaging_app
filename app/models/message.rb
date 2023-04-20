class Message < ApplicationRecord
  belongs_to :phone
  belongs_to :provider

  validates :message_id, presence: true, uniqueness: true
  validates :delivery_status,
            presence: true,
            inclusion: { in: %w(pending delivered failed invalid) }
end