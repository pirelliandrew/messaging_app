# frozen_string_literal: true

module Messages
  class Create < ActiveInteraction::Base
    string :phone_number, :message

    attr_reader :response_status

    set_callback :filter, :before, -> { @response_status = 400 }

    validates :phone_number, :message, presence: true

    def execute
      phone = Phone.find_by(number: phone_number) || compose(Phones::Create, phone_number:)

      return if errors.present?

      if phone.blacklisted?
        @response_status = 403
        errors.add(:phone_number, 'has been blacklisted')
        return
      end

      message_attempt = send_message_with_retry(phone)

      unless message_attempt.sending?
        @response_status = 503
        errors.add(:all_messaging_providers, 'are currently unavailable')
        return
      end

      @response_status = 201
      message_attempt
    end

    private

    def send_message_with_retry(phone)
      message_attempt = Message.new(phone:)
      message_attempt.text = message
      provider_count = Provider.count
      failed_attempts = 0
      failed_providers = []

      while failed_attempts < provider_count
        begin
          message_attempt.provider = compose(Providers::Select, failed_providers:)
          message_attempt.send_text!
          break
        rescue HTTParty::ResponseError
          failed_providers << message_attempt.provider
          failed_attempts += 1
        end
      end

      message_attempt
    end
  end
end
