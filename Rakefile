# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks
task :runp do
  sh %(foreman start web >> log/production.log 2>&1 &)
end

task :run do
  sh %(foreman start dev >> log/development.log 2>&1 &)
end

task :stop do
  pid = `cat tmp/pids/server.pid`
  sh %(kill #{pid})
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
