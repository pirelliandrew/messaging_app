# frozen_string_literal: true

module Phone
  class Create < ActiveInteraction::Base
    string :phone_number

    validates :phone_number, presence: true

    def execute
      phone = Phone.create(phone_number:)

      # 2. Add error and return 400 if Phone record is invalid
      unless phone.valid?
        response_status = 400
        errors.merge!(phone.errors)
      end

      phone
    end
  end
end
