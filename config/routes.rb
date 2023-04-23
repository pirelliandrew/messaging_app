# frozen_string_literal: true

Rails.application.routes.draw do
  post 'send_message', to: 'messaging#create'
  post 'delivery_status', to: 'messaging#update'
  get 'list_messages', to: 'messaging#index'
  root to: redirect('list_messages')
end
