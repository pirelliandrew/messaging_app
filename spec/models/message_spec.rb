require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:phone) { Phone.create(number: '1234567890') }
  let(:provider) { Provider.create(url: 'https://example.com') }

  subject { described_class.new(message_id: 'test', delivery_status: 'pending', phone:, provider:) }

  describe 'validations' do
    it { expect(subject).to validate_presence_of(:message_id) }
    it { expect(subject).to validate_uniqueness_of(:message_id) }
    it { expect(subject).to validate_presence_of(:delivery_status) }
    it { expect(subject).to validate_inclusion_of(:delivery_status).in_array(%w(pending delivered failed invalid)) }
  end

  describe 'associations' do
    it { expect(subject).to belong_to(:phone) }
    it { expect(subject).to belong_to(:provider) }
  end
end
