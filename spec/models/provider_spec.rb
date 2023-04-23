# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject { described_class.new(url: 'http://www.example.com') }

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:url) }
    it { expect(subject).to validate_uniqueness_of(:url) }
    it { expect(subject).to validate_numericality_of(:call_count).is_greater_than_or_equal_to(0) }
    it { expect(subject).to validate_presence_of(:call_ratio) }
    it {
      expect(subject).to validate_numericality_of(:call_ratio).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100)
    }

    it 'validates the format of url' do
      expect(subject).to allow_value('http://www.example.com').for(:url)
      expect(subject).to allow_value('https://www.example.com').for(:url)
      expect(subject).to_not allow_value('example.com').for(:url)
      expect(subject).to_not allow_value('ftp://example.com').for(:url)
    end
  end
end
