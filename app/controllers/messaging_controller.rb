# frozen_string_literal: true

class MessagingController < ApplicationController
  def create
    outcome = Messages::Create.run(
      phone_number: params[:phone_number],
      message: params[:message]
    )

    if outcome.valid?
      render json: { message: 'Message successfully created' }, status: outcome.response_status
    else
      render json: { error_message: outcome.errors.full_messages.to_sentence },
             status: outcome.response_status
    end
  end

  def update
    outcome = Messages::Update.run(
      message_id: params[:message_id],
      status: params[:status]
    )

    if outcome.valid?
      render json: { message: 'Message successfully updated' }, status: outcome.response_status
    else
      render json: { error_message: outcome.errors.full_messages.to_sentence },
             status: outcome.response_status
    end
  end

  def index; end
end
