# frozen_string_literal: true

class Message < ApplicationRecord
  include AASM

  attr_accessor :text

  belongs_to :phone
  belongs_to :provider

  validates :message_id, presence: true
  validates :state,
            presence: true,
            inclusion: { in: %w[pending sending delivered failed blacklisted] }

  aasm column: :state do
    state :pending, initial: true
    state :sending, :delivered, :failed, :blacklisted

    event :send_text do
      before do
        self.message_id = provider.send_text_message(self)
      end

      transitions from: :pending, to: :sending
    end

    event :mark_delivered do
      transitions from: :sending, to: :delivered
    end

    event :mark_failed do
      transitions from: :sending, to: :failed
    end

    event :mark_blacklisted do
      transitions from: :sending, to: :blacklisted
    end
  end
end
