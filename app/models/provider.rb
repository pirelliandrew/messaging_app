class Provider < ApplicationRecord
  validates :url, presence: true, uniqueness: true
  validate :validate_url_format

  private

  def validate_url_format
    return if url.blank?

    uri = URI.parse(url)
    errors.add(:url, "is not a valid URL") unless uri.is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    errors.add(:url, "is not a valid URL")
  end
end