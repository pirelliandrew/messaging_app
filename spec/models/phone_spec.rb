# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Phone, type: :model do
  subject { described_class.new(number: '1234567890') }

  describe 'validations' do
    it { expect(subject).to validate_uniqueness_of(:number).case_insensitive }
    it { expect(subject).to validate_presence_of(:number) }
    it { expect(subject).to allow_value('1234567890').for(:number) }
    it { expect(subject).to_not allow_value('123-456-7890').for(:number).with_message('for phone only allows numbers') }
  end
end
