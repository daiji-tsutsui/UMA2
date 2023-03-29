# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/service_status', to: 'service_status#status'

  root 'race#index'
  get '/races',        to: 'race#index',  as: :races
  get '/races/(:id)',  to: 'race#show',   as: :race
  get '/horses',       to: 'horse#index', as: :horses
  get '/horses/(:id)', to: 'horse#show',  as: :horse
  get '/stats',        to: 'stats#index', as: :stats
  get '/stats/api',    to: 'stats#api'

  get  '/schedules',       to: 'schedule_rule#index', as: :schedule_rules
  get  '/schedules/new',   to: 'schedule_rule#new',   as: :new_schedule
  post '/schedules/new',   to: 'schedule_rule#create'
  get  '/schedules/(:id)', to: 'schedule_rule#edit', as: :schedule_rule
  post '/schedules/(:id)', to: 'schedule_rule#update'

  mount Sidekiq::Web, at: '/sidekiq'
end
