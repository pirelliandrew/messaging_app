# frozen_string_literal: true

require 'httparty'

class Provider < ApplicationRecord
  validates :call_count, numericality: { greater_than_or_equal_to: 0 }
  validates :call_ratio, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :url, presence: true, uniqueness: true
  validate :validate_url_format

  def send_text_message(message)
    Provider.update_counters(id, call_count: 1)

    response = HTTParty.post(
      url,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        to_number: message.phone.number,
        message: message.text,
        # TODO: Update this to use ngrok subdomain
        callback_url: 'https://example.com/delivery_status'
      }.to_json
    )

    response.raise_error unless response.ok?

    response.parsed_response['message_id']
  end

  private

  def validate_url_format
    return if url.blank?

    uri = URI.parse(url)
    errors.add(:url, 'is not a valid URL') unless uri.is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    errors.add(:url, 'is not a valid URL')
  end
end
