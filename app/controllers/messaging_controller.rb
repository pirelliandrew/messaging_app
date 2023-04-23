# frozen_string_literal: true

class MessagingController < ApplicationController
  def create
    outcome = Messages::Create.run(
      phone_number: params[:phone_number],
      message: params[:message]
    )

    if outcome.valid?
      render json: { message: 'Message successfully created' }, status: :created
    else
      render json: { error_message: outcome.errors.full_messages.to_sentence },
             status: outcome.response_status
    end
  end

  def update; end

  def index; end
end
