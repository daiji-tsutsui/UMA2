# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task :runp do
  sh %(foreman start web &)
  sh %(foreman start worker1 &)
  sh %(foreman start worker2 &)
  sh %(foreman start worker3 &)
  sh %(foreman start worker4 &)
end

task :run do
  sh %(foreman start dev >> log/stdout_dev.log 2>&1 &)
  sh %(foreman start worker1 >> log/sidekiq_dev.log 2>&1 &)
  sh %(foreman start worker2 >> log/sidekiq_dev.log 2>&1 &)
  sh %(foreman start worker3 >> log/sidekiq_dev.log 2>&1 &)
  sh %(foreman start worker4 >> log/sidekiq_dev.log 2>&1 &)
end

task :stop do
  pid = `cat tmp/pids/server.pid`
  sh %(kill #{pid})
  puts 'Stop Sidekiq server manually, please...'
  puts '  See log/sidekiq_dev.log or log/sidekiq.log for getting pid.'
end

desc 'Run rubocop'
task :rubo, [:filename] do |_task, args|
  if args[:filename].nil?
    sh %(bundle exec rubocop)
  else
    sh %(bundle exec rubocop #{args[:filename]})
  end
end

desc 'Run rubocop with -a option'
task :ruboa, [:filename] do |_task, args|
  if args[:filename].nil?
    sh %(bundle exec rubocop -a)
  else
    sh %(bundle exec rubocop -a #{args[:filename]})
  end
end

desc 'Run rubocop with -A option'
task :ruboA, [:filename] do |_task, args|
  if args[:filename].nil?
    sh %(bundle exec rubocop -A)
  else
    sh %(bundle exec rubocop -A #{args[:filename]})
  end
end

desc 'Run tests except for web scraping'
task :t do
  sh %(rspec --exclude-pattern "spec/scraping/*_spec.rb")
end

desc 'Run tests with test db migration'
task :tmig do
  sh %(RAILS_ENV=test rails db:migrate:reset)
  sh %(rspec --exclude-pattern "spec/scraping/*_spec.rb")
end
