web: RAILS_ENV=production bundle exec rails server -p ${PORT} -b 0.0.0.0
dev: RAILS_ENV=development bundle exec rails server -p ${PORT} -b 0.0.0.0
worker1: bundle exec sidekiq -C config/sidekiq.yml -c 1 -q default
worker2: bundle exec sidekiq -C config/sidekiq.yml -c 1 -q default
worker3: bundle exec sidekiq -C config/sidekiq.yml -c 1 -q default
worker4: bundle exec sidekiq -C config/sidekiq.yml -c 1 -q default
