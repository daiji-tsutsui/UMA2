web: RAILS_ENV=production bundle exec rails server -p ${PORT} -b 0.0.0.0
dev: RAILS_ENV=development bundle exec rails server -p ${PORT} -b 0.0.0.0
worker: bundle exec sidekiq -C config/sidekiq.yml
