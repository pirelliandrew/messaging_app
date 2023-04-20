require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject { described_class.new(url: 'http://www.example.com') }

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:url) }
    it { expect(subject).to validate_uniqueness_of(:url) }

    it 'validates the format of url' do
      expect(subject).to allow_value('http://www.example.com').for(:url)
      expect(subject).to allow_value('https://www.example.com').for(:url)
      expect(subject).to_not allow_value('example.com').for(:url)
      expect(subject).to_not allow_value('ftp://example.com').for(:url)
    end
  end
end
