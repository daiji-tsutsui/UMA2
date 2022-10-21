# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/service_status', to: 'service_status#status'

  root 'race#index'
  get '/races', to: 'race#index'
  get '/races/:id', to: 'race#show', as: 'race'
end
