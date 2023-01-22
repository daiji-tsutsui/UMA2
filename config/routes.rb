# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/service_status', to: 'service_status#status'

  root 'race#index'
  get '/races',     to: 'race#index', as: :races
  get '/races/:id', to: 'race#show',  as: :race

  mount Sidekiq::Web, at: '/sidekiq'
end
