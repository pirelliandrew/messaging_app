# frozen_string_literal: true

class MessagingController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    outcome = Messages::Create.run(
      phone_number: params[:phone_number],
      message: params[:message]
    )

    message = outcome.valid? ? 'Message successfully created' : outcome.errors.full_messages.to_sentence
    render json: { message: }, status: outcome.response_status
  end

  def update
    outcome = Messages::Update.run(
      message_id: params[:message_id],
      status: params[:status]
    )

    message = outcome.valid? ? 'Message successfully updated' : outcome.errors.full_messages.to_sentence
    render json: { message: }, status: outcome.response_status
  end

  def index
    @messages = Messages::List.run!(phone_number: params[:phone_number])
  end
end
