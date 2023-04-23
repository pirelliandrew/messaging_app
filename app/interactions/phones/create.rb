# frozen_string_literal: true

module Phones
  class Create < ActiveInteraction::Base
    string :phone_number

    validates :phone_number, presence: true

    def execute
      phone = Phone.create(number: phone_number)

      unless phone.valid?
        errors.merge!(phone.errors)
        return
      end

      phone
    end
  end
end
