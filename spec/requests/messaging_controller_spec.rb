# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MessagingControllers', type: :request do
  describe 'POST /send_message' do
    subject { post '/send_message', params: { phone_number:, message: } }

    let!(:provider_1) { Provider.create!(call_ratio: 30, url: 'https://example.com/provider1') }
    let!(:provider_2) { Provider.create!(call_ratio: 70, url: 'https://example.com/provider2') }
    let(:provider_response) do
      double(
        HTTParty::Response,
        ok?: true,
        parsed_response: { 'message_id' => 'test message id' }
      )
    end

    before { allow(HTTParty).to receive(:post).and_return(provider_response) }

    shared_examples 'a request that fails validations' do
      it 'does not send a request to any provider' do
        expect(HTTParty).not_to receive(:post)

        subject
      end

      it 'does not create a message' do
        expect { subject }.not_to change { Message.count }
      end
    end

    shared_examples 'a 201 response' do
      it 'sends a request to the expected provider(s)' do
        subject

        expected_provider_urls.each do |provider_url|
          expect(HTTParty).to have_received(:post).with(
            provider_url,
            headers: { 'Content-Type' => 'application/json' },
            body: {
              to_number: '1234567890',
              message: 'test message text',
              callback_url: 'https://example.com/delivery_status'
            }.to_json
          )
        end
      end

      it "creates a message in the 'sending' state" do
        expect { subject }.to change { Message.count }.from(0).to(1)

        new_message = Message.first

        expect(new_message.state).to eq('sending')
        expect(new_message.provider_id).to eq(expected_provider.id)
        expect(new_message.phone.number).to eq(phone_number)
      end

      it 'returns a 201 response with a descriptive message' do
        subject

        expect(response).to have_http_status(201)
        expect(response.body).to include('Message successfully created')
      end
    end

    shared_examples 'a 400 response' do
      it_behaves_like 'a request that fails validations'

      it 'returns a 400 response with a descriptive error message' do
        subject

        expect(response).to have_http_status(400)
        expect(response.body).to include(expected_error_message)
      end
    end

    shared_examples 'a 403 response' do
      it_behaves_like 'a request that fails validations'

      it 'returns a 403 response with a descriptive error message' do
        subject

        expect(response).to have_http_status(403)
        expect(response.body).to include('Phone number has been blacklisted')
      end
    end

    shared_examples 'a 503 response' do
      it 'sends a request to each provider' do
        subject

        Provider.pluck(:url).each do |provider_url|
          expect(HTTParty).to have_received(:post).with(
            provider_url,
            headers: { 'Content-Type' => 'application/json' },
            body: {
              to_number: '1234567890',
              message: 'test message text',
              callback_url: 'https://example.com/delivery_status'
            }.to_json
          )
        end
      end

      it 'does not create a message' do
        expect { subject }.not_to change { Message.count }
      end

      it 'returns a 503 response with a descriptive error message' do
        subject

        expect(response).to have_http_status(503)
        expect(response.body).to include('All messaging providers are currently unavailable')
      end
    end

    context 'when no phone_number is provided' do
      let(:phone_number) { nil }
      let(:message) { 'test message text' }
      let(:expected_error_message) { 'Phone number is required' }

      it_behaves_like 'a 400 response'
    end

    context 'when no message is provided' do
      let(:phone_number) { '1234567890' }
      let(:message) { nil }
      let(:expected_error_message) { 'Message is required' }

      it_behaves_like 'a 400 response'
    end

    context 'when a phone number with an invalid format is provided' do
      let(:phone_number) { 'abcdefghji' }
      let(:message) { 'test message text' }
      let(:expected_error_message) { 'Number for phone only allows numbers' }

      it_behaves_like 'a 400 response'
    end

    context 'when a phone_number and message with valid formats are provided' do
      let(:phone_number) { '1234567890' }
      let(:message) { 'test message text' }

      context 'when a Phone record with the specified phone number does not exist' do
        let(:expected_provider_urls) { ['https://example.com/provider2'] }
        let(:expected_provider) { provider_2 }

        it 'creates a Phone record' do
          expect { subject }.to change { Phone.count }.from(0).to(1)
          expect(Phone.first.number).to eq(phone_number)
        end

        it_behaves_like 'a 201 response'
      end

      context 'when a Phone record with the specified phone number exists' do
        let!(:phone) { Phone.create!(number: phone_number) }

        context 'when the phone_number is blacklisted' do
          before { phone.update!(blacklist: true) }

          it_behaves_like 'a 403 response'
        end

        context 'when the phone_number is not blacklisted' do
          context 'when all the providers are up' do
            let(:expected_provider_urls) { ['https://example.com/provider2'] }
            let(:expected_provider) { provider_2 }

            it_behaves_like 'a 201 response'
          end

          context 'when the first selected provider is down' do
            let(:expected_provider_urls) { %w[https://example.com/provider1 https://example.com/provider2] }
            let(:expected_provider) { provider_1 }
            let(:provider_error_response) { double(HTTParty::Response, ok?: false) }

            before do
              allow(HTTParty)
                .to receive(:post)
                .with(provider_2.url, headers: anything, body: anything)
                .and_return(provider_error_response)
              allow(provider_error_response)
                .to receive(:raise_error)
                .and_raise(HTTParty::ResponseError, 'Internal server error')
            end

            it_behaves_like 'a 201 response'
          end

          context 'when all the providers are down' do
            let(:provider_error_response) { double(HTTParty::Response, ok?: false) }

            before do
              allow(HTTParty)
                .to receive(:post)
                .and_return(provider_error_response)
              allow(provider_error_response)
                .to receive(:raise_error)
                .and_raise(HTTParty::ResponseError, 'Internal server error')
            end

            it_behaves_like 'a 503 response'
          end
        end
      end

      context 'when multiple requests are sent' do
        it 'sends 30% of requests to provider 1' do
          provider_call_count = 0
          allow(HTTParty).to receive(:post) do |url|
            provider_call_count += 1 if url == provider_1.url
            double(
              HTTParty::Response,
              ok?: true,
              parsed_response: { 'message_id' => SecureRandom.uuid }
            )
          end

          10.times { post '/send_message', params: { phone_number:, message: } }

          expect(provider_call_count).to eq(3)
        end

        it 'sends 70% of requests to provider 2' do
          provider_call_count = 0
          allow(HTTParty).to receive(:post) do |url|
            provider_call_count += 1 if url == provider_1.url
            double(
              HTTParty::Response,
              ok?: true,
              parsed_response: { 'message_id' => SecureRandom.uuid }
            )
          end

          10.times { post '/send_message', params: { phone_number:, message: } }

          expect(provider_call_count).to eq(3)
        end
      end
    end
  end

  describe 'POST /delivery_status' do
    subject { post '/delivery_status', params: { message_id:, status: } }

    shared_examples 'a 200 response' do
      it 'updates the status of the message' do
        expect { subject }
          .to change { message.reload.state }
          .from('sending')
          .to(expected_state)
      end

      it 'returns a 200 response with a descriptive message' do
        subject

        expect(response).to have_http_status(200)
        expect(response.body).to include('Message successfully updated')
      end
    end

    shared_examples 'a 400 response' do
      it 'returns a 400 response with a descriptive error message' do
        subject

        expect(response).to have_http_status(400)
        expect(response.body).to include(expected_error_message)
      end
    end

    shared_examples 'a 404 response' do
      it 'returns a 404 response with a descriptive error message' do
        subject

        expect(response).to have_http_status(404)
        expect(response.body).to include('Message with the provided message_id does not exist')
      end
    end

    let(:phone) { Phone.create!(number: '1234567890') }
    let(:provider) { Provider.create!(call_ratio: 30, url: 'https://example.com/provider1') }

    context 'when no message_id is provided' do
      let(:message_id) { nil }
      let(:status) { 'delivered' }
      let(:expected_error_message) { 'Message is required' }

      it_behaves_like 'a 400 response'
    end

    context 'when no status is provided' do
      let(:message_id) { 'test message id' }
      let(:status) { nil }
      let(:expected_error_message) { 'Status is required' }

      it_behaves_like 'a 400 response'
    end

    context 'when a Message record with the specified message_id does not exist' do
      let(:message_id) { 'test message id' }
      let(:status) { 'delivered' }

      it_behaves_like 'a 404 response'
    end

    context 'when a Message record with the specified message_id exists' do
      let(:message_id) { 'test message id' }
      let!(:message) { Message.create!(message_id:, phone:, provider:, state:) }

      context 'when the message is in a sending state' do
        let(:state) { 'sending' }

        context "when an 'delivered' status is provided" do
          let(:status) { 'delivered' }
          let(:expected_state) { status }

          it_behaves_like 'a 200 response'
        end

        context "when an 'failed' status is provided" do
          let(:status) { 'failed' }
          let(:expected_state) { status }

          it_behaves_like 'a 200 response'
        end

        context "when an 'invalid' status is provided" do
          let(:status) { 'invalid' }
          let(:expected_state) { 'blacklisted' }

          it 'marks the phone associated with the message as blacklisted' do
            expect { subject }.to change { message.reload.phone.blacklist }.from(false).to(true)
          end

          it_behaves_like 'a 200 response'
        end

        context 'when any other status is provided' do
          let(:status) { 'unknown' }
          let(:expected_error_message) { 'Status has an unsupported value' }

          it 'does not update the message' do
            expect { subject }.not_to change { message.reload.attributes }
          end

          it_behaves_like 'a 400 response'
        end
      end

      context 'when the message is not in a sending state' do
        let(:state) { 'failed' }
        let(:status) { 'delivered' }
        let(:expected_error_message) { 'Message is not in a sending state' }

        it_behaves_like 'a 400 response'
      end
    end
  end
end
