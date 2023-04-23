# frozen_string_literal: true

module Messages
  class Create < ActiveInteraction::Base
    string :phone_number, :message
    integer :response_status, default: 400

    attr_accessor :response_status

    validates :phone_number, :message,
              presence: true

    def execute
      # 1. Retrieve or create Phone record for given phone number
      phone = Phone.find_by(number: phone_number) || compose(Phones::Create, phone_number:)

      return if errors.present?

      # 3. Add error and return 403 if phone number is blacklisted
      if phone.blacklisted?
        response_status = 403
        errors.add(:phone_number, 'has been blacklisted')
        return
      end

      message_attempt = send_message_with_retry(phone)

      unless message_attempt.sending?
        response_status = 503
        errors.add(:all_messaging_providers, 'are currently unavailable')
        return
      end

      response_status = 201
    end

    private

    def send_message_with_retry(phone)
      # 10. Create Message record for given Phone with pending status and message id from response
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
