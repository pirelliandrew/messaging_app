# frozen_string_literal: true

module Messages
  class List < ActiveInteraction::Base
    string :phone_number, default: nil

    def execute
      messages_with_associated_data = Message.includes(:phone, :provider)

      if phone_number.present?
        messages_with_associated_data.joins(:phone).where(phone: { number: phone_number }).all
      else
        messages_with_associated_data.all
      end
    end
  end
end
