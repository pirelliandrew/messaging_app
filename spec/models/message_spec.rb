# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:phone) { Phone.create(number: '1234567890') }
  let(:provider) { Provider.create(url: 'https://example.com') }

  subject { described_class.new(message_id: 'test', state: 'pending', phone:, provider:) }

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:message_id) }
    it { expect(subject).to validate_presence_of(:state) }
    it { expect(subject).to validate_inclusion_of(:state).in_array(%i[pending delivered failed blacklisted]) }
  end

  describe 'associations' do
    it { expect(subject).to belong_to(:phone) }
    it { expect(subject).to belong_to(:provider) }
  end
end
