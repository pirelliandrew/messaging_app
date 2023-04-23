# frozen_string_literal: true

module Message
  class Create < ActiveInteraction::Base
    string :phone_number, :message_text

    attr_accessor :response_status, :message

    validates :phone_number, :message_text,
              presence: true

    def execute
      # 1. Retrieve or create Phone record for given phone number
      phone = Phone.find_by(phone_number:) || compose(Phone::Create, phone_number:)

      return if errors.present?

      # 3. Add error and return 403 if phone number is blacklisted
      if phone.blacklisted?
        response_status = 403
        errors.add(:phone_number, 'has been blacklisted')
        return
      end

      send_message_with_retry

      unless message.sending?
        response_status = 503
        errors.add(:provider, 'All messaging providers are currently unavailable')
        return
      end

      response_status = 201
    end

    private

    def send_message_with_retry
      # 10. Create Message record for given Phone with pending status and message id from response
      message = Message.new(phone:)
      provider_count = Provider.count
      failed_attempts = 0
      failed_providers = []
      while failed_attempts < provider_count
        begin
          message.provider = compose(Provider::Select, failed_providers:)
          message.send_text(message_text)
          break
        rescue HTTParty::ResponseError
          failed_providers << message.provider
          failed_attempts += 1
        end
      end
    end
  end
end
