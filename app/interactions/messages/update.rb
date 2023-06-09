# frozen_string_literal: true

module Messages
  class Update < ActiveInteraction::Base
    string :message_id, :status

    attr_reader :response_status

    set_callback :filter, :before, -> { @response_status = 400 }

    validates :message_id, :status, presence: true

    def execute
      message = Message.find_by(message_id:)

      unless message.present?
        @response_status = 404
        errors.add(:message, 'with the provided message_id does not exist')
        return
      end

      unless message.sending?
        errors.add(:message, 'is not in a sending state')
        return
      end

      case status
      when 'delivered'
        message.mark_delivered!
      when 'failed'
        message.mark_failed!
      when 'invalid'
        message.mark_blacklisted!
      else
        errors.add(:status, 'has an unsupported value')
        return
      end

      @response_status = 200
      message
    end
  end
end
